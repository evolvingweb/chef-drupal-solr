## Cookbook Name:: drupal-solr
## Attribute:: solr

# must be one of the versions available at http://archive.apache.org/dist/lucene/solr/
# must be consistent with node['drupal-solr']['apachesolr_conf_dir']

default['drupal-solr']['drupal_root'] = ''
default['drupal-solr']['drupal_db'] = ''
default['drupal-solr']['drupal_version'] = '7'
default['drupal-solr']['version']   = '1.4.0'
default['drupal-solr']['url']       = "http://archive.apache.org/dist/lucene/solr/" +
                                       node['drupal-solr']['version'] + "/apache-solr-" +
                                       node['drupal-solr']['version']+ ".tgz"

default['drupal-solr']['app_name']  = "org"
default['drupal-solr']['home_dir']  = "/opt/solr/#{node['drupal-solr']['app_name']}"
default['drupal-solr']['make_solr_default_search'] = true

default['drupal-solr']['php_client_url'] =
  "https://solr-php-client.googlecode.com/files/SolrPhpClient.r22.2009-11-09.tgz"

default['drupal-solr']['apachesolr_install_dir'] = "#{node['drupal-solr']['drupal_root']}/sites/all/modules/apachesolr"

# directory in apachesolr module where relevant solr
# configuration files can be found to copy to solr/home
case node['drupal-solr']['drupal_version']
when '7'
  case node['drupal-solr']['version'].split(".")[0]
  when '1'
    default['drupal-solr']['apachesolr_conf_dir'] = node['drupal-solr']['apachesolr_install_dir'] + "/solr-conf/solr-1.4"
  else 
    default['drupal-solr']['apachesolr_conf_dir'] = node['drupal-solr']['apachesolr_install_dir'] + "/solr-conf/solr-" + node['drupal-solr']['version'].split(".")[0]+".x"
  end
when '6'
  default['drupal-solr']['apachesolr_conf_dir'] =
  node['drupal-solr']['apachesolr_install_dir']
end

default['drupal-solr']['mysql_root_password'] = 'root'
