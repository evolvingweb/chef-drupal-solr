## Cookbook Name:: drupal-solr
## Recipe:: default
##

include_recipe "drupal-solr::install_solr"
include_recipe "drush"

DRUSH = "drush --root='#{node['drupal-solr']['drupal_root']}'"

bash "download-apachesolr-module" do
  code "#{DRUSH} pm-download -y apachesolr-#{node['drupal-solr']['module_version']}"
  not_if "#{DRUSH} pm-list | grep apachesolr"
end

src_filepath = "#{Chef::Config['file_cache_path']}/SolrPhpClient.r22.2009-11-09.tgz"
solr_module_path_cmd = "#{DRUSH} php-eval \"print DRUPAL_ROOT . '/' . drupal_get_path('module', 'apachesolr');\""

remote_file "download-solrPhpClient" do
  source "https://solr-php-client.googlecode.com/files/SolrPhpClient.r22.2009-11-09.tgz"
  path src_filepath
  action :create_if_missing
  not_if { node['drupal-solr']['module_version'].match /^6.x-3|^7|8/ }
end

bash 'install-solrPhpClient' do
  code <<-EOH
    #{DRUSH} cc module-list
    cd $(#{solr_module_path_cmd})
    tar xzf #{src_filepath}
  EOH
  not_if "test -d $(#{solr_module_path_cmd})/SolrPhpClient"
  not_if { node['drupal-solr']['module_version'].match /^6.x-3|^7|8/ }
end

bash "enable-apachesolr-module" do
  code "#{DRUSH} pm-enable -y apachesolr_search"
  not_if "#{DRUSH} pm-list | grep apachesolr_search | grep Enabled"
end

execute "install-drupalized-solr-conf" do
  command <<-EOT
    cd $(#{solr_module_path_cmd})/#{node['drupal-solr']['conf_source']}
    cp protwords.txt schema.xml solrconfig.xml #{node['drupal-solr']['home_dir']}/conf
  EOT
  action :nothing
  subscribes :run, "bash[install-example-solr-home]", :delayed
  notifies :run, "execute[fix-perms-solr-home]"
  notifies :restart, "service[tomcat]", :immediately # immediately - otherwise tomcat will restart too soon; chef bug?
end

execute "fix-perms-solr-home" do
  cwd node['drupal-solr']['home_dir']
  command "chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} ."
  action :nothing
end

execute "set-d7-solr-url" do
  command "#{DRUSH} solr-set-env-url http://localhost:#{node['tomcat']['port']}/#{node['drupal-solr']['app_name']}"
  only_if { node['drupal-solr']['module_version'].match /^6.x-3|^7|8/ }
end

execute "set-d6-solr-url" do
  command <<-EOH
    #{DRUSH} variable-set apachesolr_port #{node['tomcat']['port']}
    #{DRUSH} variable-set apachesolr_path /#{node['drupal-solr']['app_name']}
  EOH
  not_if {node['drupal-solr']['module_version'].match /^6.x-3|^7|8/ }
end

execute "set-solr-as-default-search" do
  command "#{DRUSH} vset search_default_module apachesolr_search"
  only_if { node['drupal-solr']['make_solr_default_search'] }
end
