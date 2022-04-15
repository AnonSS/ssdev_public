# Base profile for Linux OS
class profile::base_linux (
  Boolean $awscli   = false,
  Boolean $postfix  = false,
  Boolean $graylog  = false,
  Boolean $nsswitch = false,
  Boolean $ntp      = false,
) {
  include network
  # include archive
  include ::firewalld
  include ssh
  include accounts
  include cron
  include ::collectd
  include puppet_agent

  # include nsswitch
  if $postfix {
    include postfix
  }
  if $graylog {
    include rsyslog
    include rsyslog::config
  }
# config: /etc/systemd/system/node_exporter.service
  class { 'prometheus::node_exporter':
    version       => '1.1.2',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }
  #   $fqdn = $::facts['networking']['fqdn']
  # @@profile::prometheus::target { "${fqdn} - node_exporter":
  #   job  => 'node',
  #   host => "${fqdn}:9100",
  # }
  # Postfix -- test message: echo "My messagetd" | mail -s subject sym1@lsst.org
  # mailx -- delete all messages: postsuper -d ALL
  # postfix::config { 'relayhost':
  #   ensure => present,
  #   value  => '140.252.32.25',
  # }
  # class { 'postfix':
  #   # inet_interfaces     => 'localhost',
  #   # inet_protocols      => 'ipv4',
  #   relayhost           => '140.252.32.25',
  #   root_mail_recipient => 'shahram@lsst.org',
  # }

  # postfix::config { 'relay_domains':
  #   ensure => present,
  #   value  => 'mail.lsst.org',
  #   root_mail_recipient => 'shahram@lsst.org',
  # }
  # if $ntp {
    class { 'chrony':
      servers => [ '140.252.1.140', '140.252.1.141', '0.pool.ntp.arizona.edu' ],
    }
  # }
  class { 'timezone':
      timezone => 'UTC',
  }
  Package { [ 'git', 'tree', 'tcpdump', 'telnet', 'lvm2', 'gcc', 'xinetd',
  'bash-completion', 'sudo', 'vim', 'openssl', 'openssl-devel',
  'acpid', 'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute',
  'gzip', 'tar', 'unzip', 'net-tools', 'fping' ]:
  ensure => installed,
  }
# install awscli tool
# class { 'awscli': }
if $awscli {
  Package { [ 'awscli' ]:
    ensure => installed,
  }
  # archive { '/tmp/awscli-bundle.zip':
  #   ensure   => present,
  #   source   => 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip',
  #   provider => 'wget',
  #   cleanup  => false,
  # }
  # archive { '/tmp/awscli-bundle.zip':
  #   path         => '/tmp',
  #   source       => 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip',
  #   extract      => true,
  #   extract_path => '/usr/local/aws',
  #   creates      => '/usr/local/bin',
  #   cleanup      => true,
  # # require      => File['wso2_appdir'],
  # }
  # file { '/opt/tomcat/webapps/pwm.war':
  #   ensure => present,
  #   source => '/tmp/pwm-1.9.2.war',
  # }
  $awscreds = lookup('awscreds')
    file {
      '/root/.aws':
        ensure => directory,
        mode   => '0700',
        ;
      '/root/.aws/credentials':
        ensure  => file,
        mode    => '0600',
        content => $awscreds,
        ;
      '/root/.aws/config':
        ensure  => file,
        mode    => '0600',
        content => "[default]\n",
    }
}
# Modify these files to secure servers
  $host = lookup('host')
  file { '/etc/host.conf' :
    ensure  => file,
    content => $host,
  }
  if $nsswitch {
    class { 'nsswitch':
    hosts  => ['dns myhostname','files'],
    }
  }
  # $nsswitch = lookup('nsswitch')
  # file { '/etc/nsswitch.conf' :
  #   ensure  => file,
  #   content => $nsswitch,
  # }
  $sshd_banner = lookup('sshd_banner')
  file { '/etc/ssh/sshd_banner' :
    ensure  => file,
    content => $sshd_banner,
  }
  $denyhosts = lookup ('denyhosts')
  file { '/etc/hosts.deny' :
    ensure  => file,
    content => $denyhosts,
  }
  $allowhosts = lookup ('allowhosts')
  file { '/etc/hosts.allow' :
    ensure  => file,
    content => $allowhosts,
  }
}
