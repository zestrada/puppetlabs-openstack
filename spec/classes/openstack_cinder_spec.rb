require 'spec_helper'

describe 'openstack::cinder' do

  let :default_params do {
      :sql_connection     => 'mysql://user:pass@host/dbname/',
      :rabbit_password    => 'rabbit_pw',
      :iscsi_ip_address   => '127.0.0.1'
    }
  end

  let :facts do {
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
    }
  end

  describe "when using default class parameters" do

    let :params do
      default_params
    end

    it {
      should contain_class('cinder::base').with(
        :sql_connection      => 'mysql://user:pass@host/dbname/',
        :rabbit_host         => '127.0.0.1',
        :rabbit_userid       => 'nova',
        :rabbit_password     => 'rabbit_pw',
        :verbose             => 'false'
      )

      should contain_class('cinder::volume').with(
        :enabled     => 'true'
      )

      should contain_class('cinder::volume::iscsi').with(
        :volume_group     => 'nova-volumes',
        :iscsi_ip_address => '127.0.0.1'
      )

      should_not contain_class('cinder::api')
      should_not contain_class('cinder::scheduler')

    }
  end

  describe "when overriding parameters, but not enabling scheduler or api" do
    
    let :override_params do {
      :sql_connection     => 'mysql://user:pass@host/dbname2/',
      :rabbit_password    => 'rabbit_pw2',
      :iscsi_ip_address   => '127.0.0.2',
      :verbose            => 'true',
      :iscsi_ip_address   => '127.0.0.2'
    }

    end

    let :params do
      default_params.merge(override_params)
    end

    it {

      should contain_class('cinder::base').with(
        :sql_connection     => 'mysql://user:pass@host/dbname2/',
        :rabbit_password    => 'rabbit_pw2',
        :verbose            => 'true'
      )

      should contain_class('cinder::volume').with(
        :enabled     => 'true'
      )

      should contain_class('cinder::volume::iscsi').with(
        :volume_group     => 'nova-volumes',
        :iscsi_ip_address => '127.0.0.2'
      )

      should_not contain_class('cinder::api')
      should_not contain_class('cinder::scheduler')
    }

    end

  describe "when using default class parameters and enabling scheduler and api" do

    let :params do
      default_params.merge(
        {
          :config_api          => 'true',
          :config_scheduler    => 'true'
        }
      )
    end

    it {
      should contain_class('cinder::base').with(
        :sql_connection      => 'mysql://user:pass@host/dbname/',
        :rabbit_host         => '127.0.0.1',
        :rabbit_userid       => 'nova',
        :rabbit_password     => 'rabbit_pw',
        :verbose             => 'false'
      )

      should contain_class('cinder::volume').with(
        :enabled     => 'true'
      )

      should contain_class('cinder::volume::iscsi').with(
        :volume_group     => 'nova-volumes',
        :iscsi_ip_address => '127.0.0.1'
      )

      should contain_class('cinder::api').with(
        :keystone_password      => 'keystone',
        :keystone_enabled       => 'true',
        :keystone_tenant        => 'services',
        :keystone_user          => 'cinder',
        :keystone_auth_host     => 'localhost',
        :keystone_auth_port     => '35357',
        :keystone_auth_protocol => 'http',
        :package_ensure         => 'latest',
        :bind_host              => '0.0.0.0'
      )

      should contain_class('cinder::scheduler').with(
        :package_ensure         => 'latest'
      )
    }
  end

  describe "when using non-default class parameters and enabling scheduler and api" do

    let :params do
      default_params.merge(
        {
          :config_api             => 'true',
          :config_scheduler       => 'true',
          :sql_connection         => 'mysql://user:pass@host/dbname2/',
          :rabbit_password        => 'rabbit_pw2',
          :rabbit_userid          => 'nova2',
          :rabbit_host            => '127.0.0.2',
          :iscsi_ip_address       => '127.0.0.2',
          :volume_group           => 'nova-volumes2',
          :verbose                => 'true',
          :keystone_password      => 'keystone2',
          :keystone_enabled       => 'true',
          :keystone_tenant        => 'services2',
          :keystone_user          => 'cinder2',
          :keystone_auth_host     => 'localhost2',
          :keystone_auth_port     => '35352',
          :keystone_auth_protocol => 'https',
          :package_ensure         => 'present',
          :bind_host              => '127.0.0.2'
        }
      )
    end

    it {
      should contain_class('cinder::base').with(
        :sql_connection      => 'mysql://user:pass@host/dbname2/',
        :rabbit_host         => '127.0.0.2',
        :rabbit_userid       => 'nova2',
        :rabbit_password     => 'rabbit_pw2',
        :verbose             => 'true'
      )

      should contain_class('cinder::volume').with(
        :enabled     => 'true'
      )

      should contain_class('cinder::volume::iscsi').with(
        :volume_group       => 'nova-volumes2',
        :iscsi_ip_address   => '127.0.0.2'
      )

      should contain_class('cinder::api').with(
        :keystone_password      => 'keystone2',
        :keystone_enabled       => 'true',
        :keystone_tenant        => 'services2',
        :keystone_user          => 'cinder2',
        :keystone_auth_host     => 'localhost2',
        :keystone_auth_port     => '35352',
        :keystone_auth_protocol => 'https',
        :package_ensure         => 'present',
        :bind_host              => '127.0.0.2'
      )

      should contain_class('cinder::scheduler').with(
        :package_ensure         => 'present'
      )
    }
  end

end
