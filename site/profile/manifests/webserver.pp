# webserver
class profile::webserver {

include mysql::server
}
class { '::php::globals':
  php_version => '8.0.10',
  config_root => '/etc/php/7.0',
}
