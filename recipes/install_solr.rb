## Cookbook Name:: drupal-solr
## Recipe:: install_solr
##

include_recipe "tomcat"
include_recipe "curl"

solr_archive = "apache-solr-" + node['drupal-solr']['version']

# solr home directory
directory "#{node['drupal-solr']['home_dir']}/conf" do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end
#solr.war directory
directory node['drupal-solr']['war_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end

bash "download-solr-#{node['drupal-solr']['version']}" do
  cwd node['drupal-solr']['war_dir']
  code <<-EOH
    curl #{node['drupal-solr']['url']} | tar xz
    cp #{solr_archive}/example/webapps/solr.war .
  EOH
  creates node['drupal-solr']['war_dir'] + "/solr.war"
  notifies :restart, "service[tomcat]", :delayed
end

solr_context_file = node['tomcat']['context_dir'] + "/" +
                    node['drupal-solr']['app_name'] + ".xml"

template solr_context_file do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  source "solr_context.xml.erb"
  notifies :restart, "service[tomcat]"
end
