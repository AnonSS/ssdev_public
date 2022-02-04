## Reboot will be required following the installation of this
class profile::pwm {

  $pwmconfig_dest = lookup('pwmconfig_dest')
  $pwmconfig_source = lookup('pwmconfig_source')
  archive { '/tmp/pwm-1.9.2.war':
    ensure   => present,
    source   => 'https://github.com/pwm-project/pwm/releases/download/v1_9_2/pwm-1.9.2.war',
    provider => 'wget',
    cleanup  => false,
  }
  file { '/opt/tomcat/webapps/pwm.war':
    ensure => present,
    source => '/tmp/pwm-1.9.2.war',
  }
  # using archive directly to destination breaks tomcat installation
  # So it must first go to the tmp folder then compied over to destination.
  archive { '/tmp/PwmConfiguration.xml' :
    ensure  => present,
    source  => $pwmconfig_source,
    cleanup => false,
  }
  $pwmkeystore = lookup('pwmkeystore')
  archive { '/etc/pki/keystore' :
    ensure  => present,
    source  => $pwmkeystore,
    cleanup => false,
  }
  file { $pwmconfig_dest:
    ensure => present,
    source => '/tmp/PwmConfiguration.xml',
  }
$applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/pwm/WEB-INF/web.xml':
    ensure => present,
  }
  -> file_line { 'Append line to pwm/WEB-INF/web.xml':
      path  => $webpath,
      line  => "<param-value>${applicationpath}</param-value>",
      match => '<param-value>unspecified</param-value>', # "^unspecified.*$" can be used for string
    }
    $lsst_theme = lookup('lsst_theme')
    file {
      '/opt/tomcat/webapps/pwm/public/resources/themes/lsst':
        ensure => directory,
    }
    archive { '/tmp/lsst.zip' :
      # path => '/tmp/lsst.zip',
      # ensure  => present,
      source  => $lsst_theme,
      cleanup => false,
      extract      => true,
      extract_path => '/opt/tomcat/webapps/pwm/public/resources/themes',
      # creates      => '/opt/tomcat/webapps/pwm/public/resources/themes/lsst',
      # require      => File['/opt/tomcat/webapps/pwm/public/resources/themes/lsst'],
    }
  # # Manage certs
  # java_ks { 'pwm:truststore':
  #   ensure       => latest,
  #   certificate  => '/tmp/ca.cert',
  #   target       => '/usr/java/jdk-11.0.2+9/lib/security/test.cert',
  #   password     => 'passpass', # Must be at least 6 characters
  #   trustcacerts => true,
  # }
}
