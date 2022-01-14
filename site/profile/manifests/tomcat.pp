# tomcat 
class profile::tomcat ( Sensitive[String]
$tomcat_user_hide,
$tomcat_pass_hide,
$catalina_home,
$catalina_base,
$version,
$java_home,
$ciphers,
){
  tomcat::install { $catalina_home:
  source_url     => "https://dlcdn.apache.org/tomcat/${version}.tar.gz",
  }
  tomcat::instance { 'default':
  catalina_home => $catalina_home,
  catalina_base => $catalina_base,
  }
# wait for tomcat service to start 
  # exec { 'wait for tomcat':
  #   command     => '/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080',
  #   refreshonly => true,
  #   subscribe   => Service['tomcat'],
  # }
    # Installs Java in '/usr/java/jdk-11.0.2+9/bin/'

  # Removes entry in: /opt/tomcat/webapps/manager/META-INF/context.xml
  # For some reason it does not remove it, had to do it manually
  # tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
  # ensure        => 'absent',
  # catalina_base => $catalina_base,
  # }
  file { '/opt/tomcat/webapps/manager/META-INF/context.xml':
    ensure => present,
  }
  -> file_line{ 'remove org.apache.catalina.valves.RemoteAddrValve':
      match => 'org.apache.catalina.valves.RemoteAddrValve',
      line  => ' ',
      path  => '/opt/tomcat/webapps/manager/META-INF/context.xml',
    }
  tomcat::config::server::tomcat_users { unwrap($tomcat_user_hide):
    password      => $tomcat_pass_hide.unwrap,
    roles         => ['admin-gui, manager-gui, manager-script'],
    catalina_base => $catalina_base,
  }
  tomcat::config::server::connector { 'default-https':
    catalina_base         => $catalina_base,
    port                  => 8443,
    protocol              =>'org.apache.coyote.http11.Http11NioProtocol', # $http_version,
    purge_connectors      => true,
    additional_attributes => {
      'redirectPort'        => absent,
      'SSLEnabled'          => $https_enabled,
      'maxThreads'          => 150,
      'scheme'              => https,
      'secure'              => true, # bool2str($https_connector_secure),
      'clientAuth'          => 'false',
      'sslProtocol'         => 'TLS',
      'sslEnabledProtocols' => 'TLSv1.2',
      'ciphers'             => $ciphers,

      'keystorePass'        => 'changeit',
      'keystoreFile'        => '/etc/pki/keystore',
    },
  }
# Getting tomcat::service to work was too painful
  $tomcat_service = @("EOT")
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=syslog.target network.target

    [Service]
    Type=forking
    SuccessExitStatus=143

    Environment=JAVA_HOME=${java_home}
    Environment=CATALINA_PID=${catalina_home}/temp/tomcat.pid
    Environment=CATALINA_HOME=${catalina_home}
    Environment=CATALINA_BASE=${catalina_base}
    Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

    ExecStart=${catalina_home}/bin/startup.sh
    ExecStop=${catalina_home}/bin/shutdown.sh

    User=tomcat
    Group=tomcat

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::unit_file { 'tomcat.service':
    content => "${tomcat_service}",
  }
  -> service { 'tomcat':
  subscribe => Tomcat::Instance['default'],
  ensure    => 'running',
  enable    => true,
  }

}
