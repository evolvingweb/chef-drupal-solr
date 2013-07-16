## Cookbook Name:: deploy-drupal
## Recipe:: solr
##

include_recipe 'tomcat::default'

DEPLOY_SITE_DIR         = node['deploy-drupal']['deploy_dir']  + "/" +
                          node['deploy-drupal']['project_name'] + "/" +
                          node['deploy-drupal']['drupal_root_dir']

SOLR_CONTEXT_FILE       = node['tomcat']['context_dir'] + "/" +
                          node['deploy-drupal']['solr']['app_name'] + ".xml"

SOLR_ARCHIVE            = "apache-solr-" + node['deploy-drupal']['solr']['version']

SOLR_PHP_CLIENT_DIR     = DEPLOY_SITE_DIR + "/" +
                          node['deploy-drupal']['solr']['apachesolr_install_dir'] +
                          "/apachesolr"
DRUSH                   = "drush --root='#{DEPLOY_SITE_DIR}'"

DB_ROOT_CONNECTION      = [ "mysql",
                            "--user='root'",
                            "--host='localhost'",
                            "--password='#{node['mysql']['server_root_password']}'",
                            "--database='#{node['deploy-drupal']['db_name']}'"
                          ].join(' ')

UPDATE_SOLR_SERVER_SQL  = [ "UPDATE apachesolr_environment",
                            "SET url=",
                            "'localhost:#{node['tomcat']['port']}/#{node['deploy-drupal']['solr']['app_name']}'",
                            "WHERE env_id = 'solr'"
                          ].join(' ')

DRUPAL_SOLR_CONF_DIR    = DEPLOY_SITE_DIR +
                          node['deploy-drupal']['solr']['apachesolr_conf_dir']

# directory containing solr.war file
# if war file is removed tomcat undeploys application
directory node['deploy-drupal']['solr']['root_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end

# solr/home directory
directory node['deploy-drupal']['solr']['home_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0775
  recursive true
end
bash "download-solr-#{node['deploy-drupal']['solr']['version']}" do
  user node['tomcat']['user']
  cwd node['deploy-drupal']['solr']['root_dir']
  code <<-EOH
    curl #{node['deploy-drupal']['solr']['url']} | tar xz
    cp #{SOLR_ARCHIVE}/example/webapps/solr.war .
    cp -Rf #{SOLR_ARCHIVE}/example/solr/. #{node['deploy-drupal']['solr']['home_dir']}/
  EOH
  creates node['deploy-drupal']['solr']['home_dir'] + "/conf/schema.xml"
  notifies :restart, "service[tomcat]", :delayed
end

template SOLR_CONTEXT_FILE do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  source "solr_context.xml.erb"
end

execute "download-apachesolr-module" do
  command "#{DRUSH} dl apachesolr -y --destination=#{node['deploy-drupal']['solr']['apachesolr_install_dir']}"
  not_if "#{DRUSH} pm-list | grep apachesolr"
  notifies :run, "bash[install-apachesolr-module]", :immediately
  notifies :run, "execute[drush-cache-clear]", :delayed
  notifies :run, "execute[drush-cron]", :delayed
end

bash "install-apachesolr-module" do
  cwd DEPLOY_SITE_DIR + "/" + node['deploy-drupal']['solr']['apachesolr_install_dir']
  code <<-EOH
    curl #{node['deploy-drupal']['solr']['php_client_url']} | tar xz
    #{DRUSH} en apachesolr apachesolr_search apachesolr_access -y
  EOH
  action :nothing
  notifies :run, "bash[drupalize-solr-conf-files]", :immediately
end

bash "drupalize-solr-conf-files" do
  cwd node['deploy-drupal']['solr']['home_dir']
  code <<-EOH
    solr_config_files=( "protwords.txt" "schema.xml" "solrconfig.xml" )
    for file in "${solr_config_files[@]}"; do
      cp conf/$file conf/$file.bak ;
      cp #{DEPLOY_SITE_DIR}/#{node['deploy-drupal']['solr']['apachesolr_conf_dir']}/$file conf/$file ;
      chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} .
    done
  EOH
  action :nothing
  notifies :run, "execute[connect-drupal-solr]", :immediately
end

# update the apachesolr_environment table to contain
# url of the installed solr server
execute "connect-drupal-solr" do
  command "#{DB_ROOT_CONNECTION} -e \"#{UPDATE_SOLR_SERVER_SQL}\""
  action :nothing
  notifies :run, "execute[set-solr-as-default-search]", :immediately
end

execute "set-solr-as-default-search" do
  command "#{DRUSH} vset search_default_module apachesolr_search"
  only_if { node['deploy-drupal']['solr']['make_solr_default_search'] == "true" }
end

# to test wether drush works:
# mysql -u root -proot --database=drupal -e "truncate table search_index" and then
# use search and see if it work

# drush cache clear
execute "drush-cache-clear" do
  command "#{DRUSH} cache-clear all"
  action :nothing
end

# run cron to index content for newly created solr search server
execute "drush-cron" do
  command "#{DRUSH} cron"
  action :nothing
end
