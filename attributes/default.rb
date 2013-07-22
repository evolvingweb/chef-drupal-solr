## Cookbook Name:: drupal-solr
## Attribute:: solr

# must be one of the versions available at http://archive.apache.org/dist/lucene/solr/
# must be consistent with node['drupal-solr']['apachesolr_conf_dir']
default['drupal-solr']['version']   = '1.4.0'
default['drupal-solr']['url']       = "http://archive.apache.org/dist/lucene/solr/" +
                                                node['drupal-solr']['version'] + "/apache-solr-" +
                                                node['drupal-solr']['version']+ ".tgz"

default['drupal-solr']['app_name']  = "org"
default['drupal-solr']['home_dir']  = "/opt/solr/#{node['drupal-solr']['app_name']}"
default['drupal-solr']['make_solr_default_search'] = true

default['drupal-solr']['php_client_url'] =
  "https://solr-php-client.googlecode.com/files/SolrPhpClient.r22.2009-11-09.tgz"
default['drupal-solr']['apachesolr_install_dir'] = "sites/all/modules"

# directory in apachesolr module where relevant solr
# configuration files can be found to copy to solr/home
default['drupal-solr']['apachesolr_conf_dir'] =
  node['drupal-solr']['apachesolr_install_dir'] +
  "/apachesolr/solr-conf/solr-" +
  node['drupal-solr']['version'].split(".")[0]+".x"

if node['drupal-solr']['version'].split(".")[0] == "1" then
  default['drupal-solr']['apachesolr_conf_dir'] =
    node['drupal-solr']['apachesolr_install_dir'] + "/apachesolr/solr-conf/solr-1.4"
end

default['drupal-solr']['drupal_root'] = ''
default['drupal-solr']['drupal_db'] = ''
