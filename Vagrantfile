# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://dl.dropbox.com/u/1537815/precise64.box"

  config.cache.auto_detect = true

  config.vm.network :forwarded_port, guest: 8080, host: 8000 # tomcat
  config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.synced_folder "./db", "/home/vagrant/drush-backups/"
  # precise64.box doesn't have chef 11, which we require
  config.vm.provision :shell, :inline => <<-HEREDOC
    gem install chef --version 11.0.0 --no-rdoc --no-ri --conservative
  HEREDOC
  
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "drupal-solr"
    chef.json.merge!({
      "drupal-solr" => {
        "drupal_root" => "/var/shared/sites/cooked.drupal/site",
        "drupal_db" => "drupal"
      }
      "minitest" =>{ 
        "recipes" => [ "deploy-drupal" ],
        "drupal_site_dir" => "/var/shared/sites/cooked.drupal/site"
      },  
    })   
  end
end
