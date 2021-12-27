## Reboot will be required following the installation of this
class profile::pwm {

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
  $applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/pwm/WEB-INF/web.xml':
    ensure => present,
  }
  -> file_line { 'Append a line to pwm/WEB-INF/web.xml':
      path  => $webpath,
      line  => "<param-value>${applicationpath}</param-value>",
      match => '<param-value>unspecified</param-value>', # "^unspecified.*$" can be used for string
    }
  # pwm configuration
  # $pwmconfig = lookup('pwmconfig')
  # file { '/opt/tomcat/webapps/pwm/WEB-INF/PwmConfiguration.xml':
  #   ensure  => present,
  #   content => $pwmconfig,
  # }
    # install awscli tool
  Package { [ 'awscli' ]:
  ensure => installed,
  }
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
  archive { '/opt/tomcat/webapps/pwm/WEB-INF/pwmPwmConfiguration.xml':
    ensure => present,
    source => 's3://pwm/PwmConfiguration_pwm2.us.lsst.org.xml',
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
