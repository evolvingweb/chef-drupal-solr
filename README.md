# Drupal-Solr Cookbook

[![BuildStatus](https://secure.travis-ci.org/amirkdv/chef-drupal-solr.png)](http://travis-ci.org/amirkdv/chef-drupal-solr)
## Description
Installs and configures an [Apache Solr](http://wiki.apache.org/solr/)
application served by Tomcat, and connects an existing Drupal site to Solr.

## Requirements
Chef >= 11.0.0

## Platforms
Tested with Vagrant and precise64.box.

## Usage with Vagrant
This repository includes an example `Vagrantfile` that spins up a virtual machine
serving Drupal and then uses this cookbook to connect Drupal to Apache Solr.
Drupal deployment is done using the
[deploy-drupal](https://github.com/amirkdv/chef-deploy-drupal) cookbook.

```bash
# requires Vagrant v1.1+
vagrant plugin install vagrant-berkshelf
vagrant up
```

## Attributes
The following are the main attributes that this cookbook uses. All attributes mentioned
below can be accessed in the cookbook via 
`node['drupal-solr']['<attribute_name>']`:

|   Attribute Name    |Default |           Description           |
| --------------------|:------:|:------------------------------: |
|`solr_version`              | `3.5.0`                  | Apache Solr version to be installed. Use `1.4.0` with Drupal 6.
|`url`                       |                          | URL to download the stated `solr_version` from.
|`app_name`                  | `solr`                   | name of the Solr Tomcat web application
|`war_dir`                   | `/opt/solr`              | absolute path to the directory containing Solr `Docroot` (`solr.war` will be placed here)
|`conf_source_glob`          | `solr-conf/solr-3.x/*`   | path to drupalized solr config files, relative to apachesolr module
|`drupal_root`               | ''                       | absolute path to the existing Drupal site
|`make_solr_default_search`  | `true`                   | sets Solr as the default search engine for Drupal
