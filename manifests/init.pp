# Puppet manifest for my PHP dev machine
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
class devweb
{
  File {
    owner   => "root",
    group   => "root",
    mode    => 644,
  }

  file { '/etc/motd':
   content => "Welcome to your Vagrant-built virtual machine! Managed by Puppet.\n"
  }

  exec {
    "grap-epel":
      command => "/bin/rpm -Ui http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm",
      creates => "/etc/yum.repos.d/epel.repo",
      alias   => "grab-epel"
      ;
    "grap-remi":
      command => "/bin/rpm -Ui http://rpms.famillecollet.com/enterprise/remi-release-6.rpm",
      creates => "/etc/yum.repos.d/remi.repo",
      alias   => "grab-remi",
      require => Exec["grab-epel"],
      ;
  }

  yumrepo {
    'remi':
        enabled => "1",
        require => Exec["grab-remi"],
  }

  package {[
      "iptables",
      "vim-enhanced",
      "subversion",
      "git",
      "nginx",
      "php",
      "php-fpm",
      "memcached",
      "mysql-server",
      "ntp",
      "samba",
      "samba-client",
      "samba-common",
    ]:
    ensure => present,
    require => Yumrepo["remi"]
  }

  package {[
      "php-gd",
      "php-mysql",
      "php-mbstring",
      "php-xml",
      "php-mcrypt",
      "php-pecl-memcache",
      "php-pecl-memcached",
      "php-soap",
    ]:
    ensure => present,
    require => [Yumrepo["remi"], Package["php"], Package["php-fpm"]],
    notify  => Service["php-fpm"]
  }

  service {
    "iptables":
      require    => Package["iptables"],
      hasstatus  => true,
      status     => "true",
      hasrestart => false
      ;
    "ntpd":
      name      => 'ntpd',
      require   => Package["ntp"],
      ensure    => running,
      enable    => true
      ;
    "nginx":
      name      => 'nginx',
      require   => Package["nginx"],
      ensure    => running,
      enable    => true
      ;
    "php-fpm":
      name      => 'php-fpm',
      require   => Package["php-fpm"],
      ensure    => running,
      enable    => true
      ;
    "mysqld":
      name      => 'mysqld',
      require   => Package["mysql-server"],
      ensure    => running,
      enable    => true
      ;
    "memcached":
      name      => 'memcached',
      require   => Package["memcached"],
      ensure    => running,
      enable    => true
      ;
    "smb":
      name      => 'smb',
      require   => Package["samba"],
      ensure    => running,
      enable    => true
      ;
    "nmb":
      name      => 'nmb',
      require   => Package["samba"],
      ensure    => running,
      enable    => true
      ;
  }

  file {
    "/etc/sysconfig/iptables":
      owner   => "root",
      group   => "root",
      mode    => 600,
      replace => true,
      ensure  => present,
      source  => "/vagrant/files/iptables.txt",
      require => Package["iptables"],
      notify  => Service["iptables"]
      ;
    "/etc/nginx/conf.d/default.conf":
      owner   => "root",
      group   => "root",
      mode    => 644,
      replace => true,
      ensure  => present,
      source  => "/vagrant/files/nginx/conf.d/default.conf",
      require => Package["nginx"],
      notify  => Service["nginx"]
      ;
    "/etc/samba/smb.conf":
      owner   => "root",
      group   => "root",
      mode    => 644,
      replace => true,
      ensure  => present,
      source  => "/vagrant/files/smb.conf",
      require => Package["samba"],
      notify  => [Service["smb"], Service["nmb"]]
      ;
    "/etc/php-fpm.d/www.conf":
      owner   => "root",
      group   => "root",
      mode    => 644,
      replace => true,
      ensure  => present,
      source  => "/vagrant/files/php-fpm.d/www.conf",
      require => Package["php-fpm"],
      notify  => Service["php-fpm"]
      ;
    "/etc/php.ini":
      owner   => "root",
      group   => "root",
      mode    => 644,
      replace => true,
      ensure  => present,
      source  => "/vagrant/files/php.ini",
      require => Package["php-fpm"],
      notify  => Service["php-fpm"]
      ;
    "/home/vagrant/logs":
        owner   => "vagrant",
        group   => "vagrant",
        ensure => "directory"
      ;
    "/home/vagrant/www":
        owner   => "vagrant",
        group   => "vagrant",
        ensure  => "directory"
      ;
    "/home/vagrant":
        owner   => "vagrant",
        group   => "vagrant",
        mode    => 711,
        ensure  => "directory"
      ;
  }

  vcsrepo { '/home/vagrant/www':
    ensure              => present,
    provider            => svn,
    source              => '....',
    basic_auth_username => '....',
    basic_auth_password => '....',
    owner               => 'vagrant',
    group               => 'vagrant',
  }

  mysql::db { 'project':
    user     => 'project',
    password => 'projectpasswd',
    host     => 'localhost',
    sql      => '/vagrant/files/dump/project.sql',
  }

  user {
    "vagrant":
      groups => ["nginx"],
      membership => minimum,
      require => Package["nginx"];
  }

  exec {
    "set samba passwd":
      command => "/bin/echo -e \"vagrant\nvagrant\n\" | /usr/bin/smbpasswd -s -a vagrant",
      require => Package["samba"],
      ;
  }
  exec {
    "set timezone":
      command => "unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime",
      ;
  }
}
include devweb
