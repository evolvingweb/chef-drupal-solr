## Cookbook Name:: deploy-drupal
## Attribute:: solr

# must be one of the versions available at http://archive.apache.org/dist/lucene/solr/
# must be consistent with node['deploy-drupal']['solr']['apachesolr_conf_dir']
default['deploy-drupal']['solr']['version']   = '1.4.0'
default['deploy-drupal']['solr']['url']       = "http://archive.apache.org/dist/lucene/solr/" +
                                                node['deploy-drupal']['solr']['version'] + "/apache-solr-" +
                                                node['deploy-drupal']['solr']['version']+ ".tgz"

default['deploy-drupal']['solr']['root_dir']  = "/opt/solr"
default['deploy-drupal']['solr']['app_name']  = "org"
default['deploy-drupal']['solr']['home_dir']  = node['deploy-drupal']['solr']['root_dir'] + "/" +
                                                node['deploy-drupal']['solr']['app_name']

default['deploy-drupal']['solr']['make_solr_default_search'] = "true"

default['deploy-drupal']['solr']['php_client_url'] = "https://solr-php-client.googlecode.com/files/SolrPhpClient.r22.2009-11-09.tgz"
default['deploy-drupal']['solr']['apachesolr_install_dir'] = "sites/all/modules"

# directory in apachesolr module where relevant solr
# configuration files can be found to copy to solr/home
# must be consistent with node['deploy-drupal']['solr']['version']
default['deploy-drupal']['solr']['apachesolr_conf_dir'] = node['deploy-drupal']['solr']['apachesolr_install_dir'] +
                                                          "/apachesolr/solr-conf/solr-1.4"
