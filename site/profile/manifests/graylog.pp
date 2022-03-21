# graylog
class profile::graylog {
  class { '::graylog::repository':
    version => '4.2'
  }
  -> class { '::graylog::server':
      config  => {
        is_master                                          => true,
        node_id_file                                       => '/etc/graylog/server/node-id',
        password_secret                                    => 'password_secret',
        root_username                                      => 'admin',
        root_password_sha2                                 => 'root_password_sha2',
        root_timezone                                      => 'UTC',
        allow_leading_wildcard_searches                    => true,
        allow_highlighting                                 => true,
        http_bind_address                                  => '0.0.0.0:9000',
        http_external_uri                                  => "https://${fqdn}:9000/",
        http_enable_tls                                    => true,
        http_tls_cert_file                                 => '/etc/ssl/graylog/graylog_cert_chain.crt',
        http_tls_key_file                                  => '/etc/ssl/graylog/graylog_key_pkcs8.pem',
        http_tls_key_password                              => 'sslkey-password',
        rotation_strategy                                  => 'time',
        retention_strategy                                 => 'delete',
        elasticsearch_max_time_per_index                   => '1d',
        elasticsearch_max_number_of_indices                => '30',
        elasticsearch_shards                               => '4',
        elasticsearch_replicas                             => '1',
        elasticsearch_index_prefix                         => 'graylog',
        elasticsearch_hosts                                => "http://${fqdn}:9200,http://${fqdn}:9200",
        mongodb_uri                                        => "mongodb://mongouser:mongopass@${fqdn}:27017",
      },
      require => Class[
        '::java',
      ],
  }
}