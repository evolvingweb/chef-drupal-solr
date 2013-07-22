name             "drupal-solr"
maintainer       "Amir Kadivar"
maintainer_email "amir@evolvingweb.ca"
license          "Apache 2.0"
description      "Installs/Configures Solr and Connects to a Drupal site"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "curl"
depends "drush"
depends "tomcat"
