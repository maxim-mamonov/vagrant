# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "puppetlabs/centos-6.6-64-puppet"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.56.60"

  config.vm.provision :shell do |shell|
    shell.inline = "puppet module install puppetlabs-stdlib --modulepath '/vagrant/modules';
                    puppet module install puppetlabs-firewall --modulepath '/vagrant/modules';

                    puppet module install spiette-ssh --modulepath '/vagrant/modules';

                    puppet module install lboynton-rpmforge --modulepath '/vagrant/modules';
                    puppet module install lboynton-remi --modulepath '/vagrant/modules';

                    puppet module install saz-motd --modulepath '/vagrant/modules';
                    puppet module install thias-selinux --modulepath '/vagrant/modules';

                    puppet module install mayflower-php --modulepath '/vagrant/modules';
                    puppet module install jfryman-nginx --modulepath '/vagrant/modules';
                    puppet module install puppetlabs-mysql --modulepath '/vagrant/modules';
                    puppet module install saz-memcached --modulepath '/vagrant/modules';

                    puppet module install willdurand-composer --modulepath '/vagrant/modules';
                    puppet module install puppetlabs-vcsrepo --modulepath '/vagrant/modules'"
  end

  config.vm.provision "puppet" do |puppet|
    puppet.module_path        = 'modules'
    puppet.hiera_config_path  = "environments/hiera.yaml"

    puppet.environment_path   = "environments"
    puppet.environment        = "development"

    puppet.manifests_path     = "environments/development"
    puppet.manifest_file      = "init.pp"
  end
end
