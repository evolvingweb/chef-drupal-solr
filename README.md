## Drupal-Solr Cookbook

[![BuildStatus](https://secure.travis-ci.org/amirkdv/chef-drupal-solr.png)](http://travis-ci.org/amirkdv/chef-drupal-solr)
#### Description
Installs and configures an [Apache Solr](http://wiki.apache.org/solr/)
application served by Tomcat, and connects an existing Drupal site to Solr.

#### Requirements
Chef >= 11.0.0

#### Platforms
Testing on this cookbook is not yet complete. Currently, the cookbook is
tested on:
* Ubuntu 12.04

#### Usage with Vagrant

This repository includes an example `Vagrantfile` that spins up a virtual machine
serving Drupal and then uses this cookbook to connect Drupal to Apache Solr.
Drupal deployment is done using the
[deploy-drupal](https://github.com/amirkdv/chef-deploy-drupal) cookbook.

To use the `Vagrantfile`, make sure you have [Vagrant
v2](http://docs.vagrantup.com/v2/installation/); do not install it as a Ruby gem
since Vagrant is [not a gem](http://mitchellh.com/abandoning-rubygems) as of version
1.1+ (i.e v2). You will also need to have the
[Vagrant-Berkshelf](https://github.com/riotgames/vagrant-berkshelf) plugin
installed:

``` bash
# have Vagrant v2 installed
vagrant plugin install vagrant-berkshelf
```

Once you have these ready, clone this repository, `cd` to the repo root, and:

``` bash
bundle install
vagrant up

```

## Attributes
The following are the main attributes that this cookbook uses. All attributes mentioned
below can be accessed in the cookbook via 
`node['drupal-solr']['<attribute_name>']`:

|   Attribute Name    |Default |           Description           |
| --------------------|:------:|:------------------------------: |
|`version`   | `1.4.0` | Apache Solr version to be installed
|`app_name`  | `solr` | name of the Solr Tomcat web application
|`war_dir`  | `/opt/solr` | absolute path to the directory containing Solr `Docroot` (`solr.war` will be placed here)
|`conf_source` | config files directory provided by the `apachesolr` module | absolute path to the directory from where solr config files (`protwords.txt`,`solrconfig.xml`, and `schema.xml` are copied to solr home
|`drupal_root` | '' | absolute path to the existing Drupal site
|`drupal_db` | '' | name of MySQL database that Drupal is using
|`mysql_root_pass`| '' | password for root access to the MySQL server Drupal is using
|`make_solr_default_search` | `true` | sets Solr as the default search engine for Drupal
|`apachesolr_install_dir` | `sites/all/modules` | directory to install Drupal integration module; relative to `drupal_root`
