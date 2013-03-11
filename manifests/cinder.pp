class openstack::cinder(
  $sql_connection,
  $rabbit_password,
  $iscsi_ip_address,
  $rabbit_host            = '127.0.0.1',
  $volume_group           = 'nova-volumes',
  $keystone_password      = 'keystone',
  $keystone_enabled       = true,
  $keystone_tenant        = 'services',
  $keystone_user          = 'cinder',
  $keystone_auth_host     = 'localhost',
  $keystone_auth_port     = '35357',
  $keystone_auth_protocol = 'http',
  $service_port           = '5000',
  $package_ensure         = 'latest',
  $bind_host              = '0.0.0.0',
  $config_api             = false,
  $enabled                = true
) {

  class { 'cinder::base':
    rabbit_password => $rabbit_password,
    rabbit_host     => $rabbit_host,
    sql_connection  => $sql_connection,
    verbose         => $verbose,
  }

  # Install / configure nova-volume
  class { 'cinder::volume':
    enabled => $enabled,
  }
  if $enabled {
    class { 'cinder::volume::iscsi':
      volume_group     => $volume_group,
      iscsi_ip_address => $iscsi_ip_address,
    }
  }
    
  # Intentionally left the default as 'false' for backwards compatibility
  if $config_api {
    class { 'cinder::api':
      keystone_password      => $keystone_password,
      keystone_enabled       => $keystone_enabled,
      keystone_tenant        => $keystone_tenant,
      keystone_user          => $keystone_user,
      keystone_auth_host     => $keystone_auth_host,
      keystone_auth_port     => $keystone_auth_port,
      keystone_auth_protocol => $keystone_auth_protocol,
      #service_port           => $service_port,
      package_ensure         => $package_ensure,
      bind_host              => $bind_host,
    }
  }
}
