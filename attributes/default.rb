## Cookbook Name:: drupal-solr
## Attribute:: default

# must be one of the versions available at http://archive.apache.org/dist/lucene/solr/
# must be consistent with node['drupal-solr']['apachesolr_conf_dir']

default['drupal-solr']['drupal_root'] = ''
default['drupal-solr']['module_version'] = "7.x-1.3"
default['drupal-solr']['solr_version']   = '3.5.0'
default['drupal-solr']['url']       = "http://archive.apache.org/dist/lucene/solr/" +
                                       node['drupal-solr']['solr_version'] + "/apache-solr-" +
                                       node['drupal-solr']['solr_version']+ ".tgz"
default['drupal-solr']['app_name']  = "solr"
default['drupal-solr']['log_format'] = "common"
default['drupal-solr']['war_dir']   = "/opt/solr"
default['drupal-solr']['home_dir']  = "/opt/solr/#{node['drupal-solr']['app_name']}"
default['drupal-solr']['make_solr_default_search'] = true

# Logic based on the following:
#   http://drupalcode.org/project/apachesolr.git/blob/refs/heads/5.x-2.x:/schema.xml
#   http://drupalcode.org/project/apachesolr.git/blob/refs/heads/6.x-1.x:/schema.xml
#   http://drupalcode.org/project/apachesolr.git/blob/refs/heads/6.x-2.x:/schema.xml
#   http://drupalcode.org/project/apachesolr.git/tree/refs/heads/6.x-3.x:/solr-conf
#   http://drupalcode.org/project/apachesolr.git/tree/refs/heads/7.x-1.x:/solr-conf
def getSolrConfPath(drupalVersion, solrVersion)
  if drupalVersion.match /^6.x-3|^7|^8/  # newer versions
    path = case solrVersion
      when /1\.4/ then '/solr-conf/solr-1.4/*'
      when /3\./ then '/solr-conf/solr-3.x/*'
      when /4\./ then '/solr-conf/solr-4.x/*'
      else raise "Unsupported solr version"
    end
  else # older versions
    path = './{protwords.txt,schema.xml,solrconfig.xml}'
  end
  return path
end

default['drupal-solr']['conf_source_glob'] = getSolrConfPath(node['drupal-solr']['module_version'], node['drupal-solr']['solr_version'])
