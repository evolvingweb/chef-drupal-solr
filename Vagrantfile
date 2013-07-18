# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64-dev"

  config.cache.auto_detect = true

  config.vm.network :forwarded_port, guest: 80, host: 8000 #apache
  config.vm.network :forwarded_port, guest: 8080, host: 8001 #tomcat
  config.vm.synced_folder "./db", "/home/vagrant/drush-backups/"
 
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "deploy-drupal::default"
    chef.add_recipe "deploy-drupal::drupal_solr"
    chef.add_recipe "minitest-handler"
    chef.json.merge!({
      "deploy-drupal" => { 
        "dev_group_name" => "vagrant",
        "solr" => { "app_name" => "my_organization" }
      },
      "tomcat" => {
        "port" => "8080"
      },
      "mysql" => {
        "server_root_password" => "root",
        "server_debian_password" => "root",
        "server_repl_password" => "root"
      },  
      "minitest" =>{ 
        "recipes" => [ "deploy-drupal::default" , "deploy-drupal::drupal_solr"],
        "drupal_site_dir" => "/var/shared/sites/cooked.drupal/site"
      },  
    })   
  end
end
