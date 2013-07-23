## Cookbook Name:: drupal-solr
## Recipe:: default
##

include_recipe "drupal-solr::install_solr"
include_recipe "drush"

DRUSH                   = "drush --root='#{node['drupal-solr']['drupal_root']}'"

DB_ROOT_CONNECTION      = [ "mysql",
                            "--user='root'",
                            "--host='localhost'",
                            "--password='#{node['drupal-solr']['mysql_root_password']}'",
                            "--database='#{node['drupal-solr']['drupal_db']}'"
                          ].join(' ')

UPDATE_SOLR_SERVER_SQL  = [ "UPDATE apachesolr_environment",
                            "SET url=",
                            "'localhost:#{node['tomcat']['port']}/#{node['drupal-solr']['app_name']}'",
                            "WHERE env_id = 'solr'"
                          ].join(' ')

DRUPAL_SOLR_CONF_DIR    = node['drupal-solr']['drupal_root'] +
                          node['drupal-solr']['apachesolr_conf_dir']

case node['drupal-solr']['drupal_version']
when /^7/
  apachesolr = "apachesolr-7.x-1.x"
when /^6/
  apachesolr = "apachesolr-6.x-1.x"
end

case node['drupal-solr']['drupal_version']
when /^7/
  apachesolr_modules = %w{"apachesolr","apachesolr_search", "apachesolr_access"}
when /^6/
  apachesolr_modules = %w{"apachesolr","apachesolr_search", "apachesolr_nodeaccess" }
end

bash "download-apachesolr-module" do
  code <<-EOH
    #{DRUSH} pm-download #{apachesolr} -y --destination=#{node['drupal-solr']['apachesolr_install_dir']}/..
    cd #{node['drupal-solr']['apachesolr_install_dir']}
    find . ! -type d -name "SolrPhpClient" && curl #{node['drupal-solr']['php_client_url']} | tar xz
    #{DRUSH} pm-enable -y #{apachesolr_modules.join(' ')}
  EOH
  not_if "#{DRUSH} pm-list | grep apachesolr"
  notifies :run, "execute[drush-cache-clear]", :immediately
end

config_files_exist = "true"
solr_config_files = %w{"protwords.txt" "schema.xml" "solrconfig.xml"}.each do |file|
  config_files_exist.insert 0, "test -f #{file} && "
end

bash "drupalize-solr-conf-files" do
  cwd node['drupal-solr']['home_dir']
  code <<-EOH
    files=( #{solr_config_files.join(' ')} )
    for file in "${files[@]}"; do
      cp #{node['drupal-solr']['conf_source']}/$file conf/$file ;
    done
    chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} .
  EOH
  not_if config_files_exist 
end

case node['drupal-solr']['drupal_version']
when /^7/
  # update the apachesolr_environment table to contain
  # url of the installed solr server
  execute "connect-drupal7-solr" do
    command "#{DB_ROOT_CONNECTION} -e \"#{UPDATE_SOLR_SERVER_SQL}\""
  end
when /^6/
  bash "connect-drupal6-solr" do
    code <<-EOH
      #{DRUSH} variable-set apachesolr_port #{node['tomcat']['port']}
      #{DRUSH} variable-set apachesolr_path /#{node['drupal-solr']['app_name']}
    EOH
  end
end

execute "set-solr-as-default-search" do
  command "#{DRUSH} vset search_default_module apachesolr_search"
  only_if { node['drupal-solr']['make_solr_default_search'] }
end

# to test wether drush works:
# mysql -u root -proot --database=drupal -e "truncate table search_index" and then
# use search and see if it work

# drush cache clear
execute "drush-cache-clear" do
  command "#{DRUSH} cache-clear all"
  action :nothing
end
