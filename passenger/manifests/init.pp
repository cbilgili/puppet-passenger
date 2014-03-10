# Class: passenger
#
#
class passenger (
  $passenger_ruby = $passenger::params::passenger_ruby,
  $passenger_version = $passenger::params::passenger_version,
  $gem_path = $passenger::params::gem_path,
  $gem_binary_path = $passenger::params::gem_binary_path,
  ) inherits passenger::params
{
  # include ruby
  package {
    "libcurl4-openssl-dev":
      before  => Exec["passenger_apache_module"],
      ensure => present;
    "apache2-threaded-dev":
      before  => Exec["passenger_apache_module"],
      ensure => present;
    "libapr1-dev":
      before  => Exec["passenger_apache_module"],
      ensure => present;
    "libaprutil1-dev":
      before  => Exec["passenger_apache_module"],
      ensure => present;
    # for ruby execjs
    "libv8-dev":
      ensure => present,
      before  => Exec["passenger_apache_module"];
  }

  exec { 
      # "/usr/local/bin/gem install passenger -v=4.0.37":
      "gem install passenger -v=${passenger_version}":
        user    => root,
        group   => root,
        alias   => "install_passenger",
        before  => Exec["passenger_apache_module"],
        # require => Class["ruby"],
        unless  => "ls ${gem_path}/gems/passenger-${passenger_version}/"
    }
    exec {
      "${gem_binary_path}/passenger-install-apache2-module --auto":
        user    => root,
        group   => root,
        path    => "/bin:/usr/bin:/usr/local/apache2/bin/",
        alias   => "passenger_apache_module",
        unless  => "ls ${gem_path}/gems/passenger-${passenger_version}/buildout/apache2/mod_passenger.so"
    }

  file { '/etc/apache2/mods-available/passenger.load':
    ensure  => present,
    content => template('passenger/passenger-load.erb'),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Exec["passenger_apache_module"],
    notify  => Service['httpd'],
  }

  file { '/etc/apache2/mods-available/passenger.conf':
    ensure  => present,
    content =>  template("passenger/passenger-enabled.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Exec["passenger_apache_module"],
    notify  => Service['httpd'],
  }

  file { '/etc/apache2/mods-enabled/passenger.load':
    ensure  => 'link',
    target  => '/etc/apache2/mods-available/passenger.load',
    owner   => '0',
    group   => '0',
    mode    => '0777',
    require => [ File['/etc/apache2/mods-available/passenger.load'], Exec["passenger_apache_module"], ],
    notify  => Service['httpd'],
  }

  file { '/etc/apache2/mods-enabled/passenger.conf':
    ensure  => 'link',
    target  => '/etc/apache2/mods-available/passenger.conf',
    owner   => '0',
    group   => '0',
    mode    => '0777',
    require => [File['/etc/apache2/mods-available/passenger.conf'], Exec["passenger_apache_module"]],
    notify  => Service['httpd'],
  }

  # LoadModule passenger_module /opt/ruby-2.0.0-p353/lib/ruby/gems/2.0.0/gems/passenger-4.0.37/buildout/apache2/mod_passenger.so
  # <IfModule mod_passenger.c>
  #   PassengerRoot /opt/ruby-2.0.0-p353/lib/ruby/gems/2.0.0/gems/passenger-4.0.37
  #   PassengerDefaultRuby /opt/ruby-2.0.0-p353/bin/ruby
  # </IfModule>

  # <VirtualHost *:80>
  #   ServerName www.yourhost.com
  #   # !!! Be sure to point DocumentRoot to 'public'!
  #   DocumentRoot /somewhere/public    
  #   <Directory /somewhere/public>
  #      # This relaxes Apache security settings.
  #      AllowOverride all
  #      # MultiViews must be turned off.
  #      Options -MultiViews
  #   </Directory>
  # </VirtualHost>
} 