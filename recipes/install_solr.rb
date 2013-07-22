## Cookbook Name:: drupal-solr
## Recipe:: install_solr
##

include_recipe "tomcat"
include_recipe "curl"

SOLR_CONTEXT_FILE       = node['tomcat']['context_dir'] + "/" +
                          node['drupal-solr']['app_name'] + ".xml"

SOLR_ARCHIVE            = "apache-solr-" + node['drupal-solr']['version']


# solr/home directory
directory node['drupal-solr']['home_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end

bash "download-solr-#{node['drupal-solr']['version']}" do
  user node['tomcat']['user']
  cwd "#{node['drupal-solr']['home_dir']}/.."
  code <<-EOH
    curl #{node['drupal-solr']['url']} | tar xz
    cp #{SOLR_ARCHIVE}/example/webapps/solr.war .
    cp -Rf #{SOLR_ARCHIVE}/example/solr/. #{node['drupal-solr']['home_dir']}/
  EOH
  creates node['drupal-solr']['home_dir'] + "/conf/schema.xml"
  notifies :restart, "service[tomcat]", :delayed
end

template SOLR_CONTEXT_FILE do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  source "solr_context.xml.erb"
  notifies :restart, "service[tomcat]"
end
