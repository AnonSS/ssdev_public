# webserver config.  SELinux should be disabled until rules are configured.
class profile::webserver {
  class { 'mysql::server':
    root_password           => 'rootpwd',
    remove_default_accounts => true,
    restart                 => true,
  }
  mysql::db { 'yourlsdb':
    user     => 'yourlsdbuser',
    password => 'yourlsdbpasswd',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  }
include nginx
include selinux
# include mysql::server

# Below this line they only need to run once.  They can be commented out after first run.
  # Package  { [ 'php-drush-drush', 'epel-release', 'yum-utils', 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm' ]:
  # ensure => installed,
  # }
  # exec { 'yum-config-manager':
  #   command => 'yum-config-manager --enable remi-php73',
  #   path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
  # }
# PHP version
# include '::php'
  class { '::php::globals':
    php_version => '7.3.31',
    # config_root => '/etc/php/7.0',
  }
  -> class { '::php':
    manage_repos => true,
    fpm          => true,
    fpm_user     => 'nginx',
    fpm_group    => 'nginx',
    settings     => {
      'PHP/max_execution_time'  => '90',
      'PHP/max_input_time'      => '300',
      'PHP/memory_limit'        => '64M',
      'PHP/post_max_size'       => '32M',
      'PHP/upload_max_filesize' => '32M',
    },
  }
  # 
# /etc/nginx/YOURLS/user/config.php #contains config settings for the YOURLS app to connect to its mysql server,
#   time settings, and the webserver. It also stores local users authorized to login to the yourls admin page.
# /etc/nginx/conf.d/yourls.conf #nginx conf file for YOURLS website and webpages.
# /etc/php-fpm.d/*.conf #php-fpm must be configured properly and running for YOURLS to render properly.
# nginx conf files: 
# /etc/nginx/nginx.conf

  file{ '/etc/nginx/YOURLS':
  ensure => directory
  }
  $ls_st_crt = lookup('ls_st_crt')
  file{ '/etc/pki/tls/certs/ls.st.crt':
  ensure  => present,
  content => $ls_st_crt,
  }
  $ls_st_key = lookup('ls_st_key')
  file{ '/etc/pki/tls/certs/ls.st.key':
  ensure  => present,
  content => $ls_st_key,
  }
  vcsrepo { '/etc/nginx/YOURLS':
    ensure             => present,
    provider           => git,
    revision           => '53f6a04c4f929bc5d444df5cb96e4074d8311a4a',
    source             => 'https://github.com/YOURLS/YOURLS.git',
    keep_local_changes => true,
  }
  $yourls_config_php = lookup('yourls_config_php')
  file{ '/etc/nginx/YOURLS/user/config.php':
  ensure  => present,
  content => $yourls_config_php
  }
  $yourls_conf = lookup('yourls_conf')
  file{ '/etc/nginx/conf.d/yourls.conf':
  ensure  => present,
  content => $yourls_conf
  }
  exec { 'chown /etc/nginx/YOURLS':
    command => 'chown -R nginx: /etc/nginx/YOURLS',
    path    => [ '/usr/local/bin/', '/bin/' ],
  }
# /etc/nginx/YOURLS/index.html
  $index_html = lookup('index_html')
  file{ '/etc/nginx/YOURLS/index.html':
  ensure  => present,
  content => $index_html
  }
}
