require 'minitest/spec'
# minitest recipe
# Cookbook Name:: deploy-drupal
# Spec:: solr
#
include MiniTest::Chef::Assertions
include MiniTest::Chef::Context
include MiniTest::Chef::Resources

# Custom Tests:
class TestSolr < MiniTest::Chef::TestCase
  def test_tomcat
    tomcat_root_url = "http://localhost:#{node['tomcat']['port']}"
    command = "curl -I #{tomcat_root_url} grep -q Apache-Coyote"
    txt = "curled #{tomcat_root_url} and expected an HTTP response from a Tomcat server"
    
    Chef::Log.info "curling #{tomcat_root_url}"
    assert_sh command , txt
  end
  def test_solr_server
    solr_ping_request = "http://localhost:#{node['tomcat']['port']}/" +
                        node['deploy-drupal']['solr']['app_name'] +
                        "/admin/ping"
    command = "curl -I #{solr_ping_request} | grep OK"
    txt = "requested solr server at #{solr_ping_request} with a wildcard query"
    
    Chef::Log.info "curling #{solr_ping_request}"
    assert_sh command , txt
  end
  def test_drupal_solr_module
    drupal_root  = node['deploy-drupal']['deploy_dir']  + "/" +
                        node['deploy-drupal']['project_name'] + "/" +
                        node['deploy-drupal']['drupal_root_dir']
    command = "drush --root=#{drupal_root} vget search_active_modules | grep apachesolr"
    txt = "expected to find apachesolr in active Drupal search modules"
    assert_sh command , txt
  end
  def test_drupal_solr_indexing 
    drupal_root = node['deploy-drupal']['deploy_dir']  + "/" +
                  node['deploy-drupal']['project_name'] + "/" +
                  node['deploy-drupal']['drupal_root_dir']
    solr_luke_request = "http://localhost:#{node['tomcat']['port']}/" +
                        node['deploy-drupal']['solr']['app_name']+
                        "/admin/luke?fl=numDocs\\&wt=json"
    minitest_log_dir = "/tmp/minitest/solr"
    system "mkdir -p #{minitest_log_dir}"
    
    # install devel and enable devel and devel_generate if necessary
    system "cd #{drupal_root}; drush dl -n devel; drush en -y devel devel_generate; drush cc all"
    # record number of indexed documents in solr
    find_num_docs =  "curl #{solr_luke_request}\
                      | sed 's/^.*\"numDocs\":\([0-9]\{1,\}\).*$/\1/'"
    Chef::Log.info "running #{find_num_docs}"
    system "echo `#{find_num_docs}` > #{minitest_log_dir}/before"
    
    # generate content via drush and index new content
    system "cd #{drupal_root}; drush generate-content 10 0;\
            drush search-index; drush solr-index"
    
    # record the number of indexed documents in solr after new content generation
    system "echo `#{find_num_docs}` > #{minitest_log_dir}/after"
    
    assert_sh "cd #{minitest_log_dir}; diff before after", "expected Solr to index new content"
  end
end
