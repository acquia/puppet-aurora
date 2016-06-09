require 'spec_helper'

describe 'aurora', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          master: true,
          scheduler_options: {
            'observer_port' => '1338',
            'libmesos_log_verbosity' => 0,
            'libprocess_port' => '8083',
            'java_opts' => [
              '-server',
              "-Djava.library.path='/usr/lib;/usr/lib64'"
            ],
            'cluster_name' => 'mesos',
            'http_port' => '8081',
            'quorum_size' => 1,
            'zookeeper' => '127.0.0.1:2181',
            'zookeeper_mesos_path' => 'mesos',
            'zookeeper_aurora_path' => 'aurora',
            'aurora_home' => '/var/lib/aurora',
            'thermos_executor_path' => '/usr/bin/thermos_executor',
            'thermos_executor_flags' => [
              '--announcer-enable',
              '--announcer-ensemble 127.0.0.1:2181',
            ],
            'allowed_container_types' => %w(DOCKER MESOS),
          },
        }
      end

      it { should compile.with_all_deps }

      it { should contain_class('aurora::scheduler') }

      it { should contain_package('aurora-tools') }
      it { should contain_package('aurora-scheduler') }

      it { should contain_exec('init-mesos-log') }

      it do
        should contain_file('/var/lib/aurora/scheduler/db')
          .with_ensure('directory')
          .with_mode('0644')
          .with_owner('aurora')
          .with_group('aurora')
          .with_require('[Package[aurora-scheduler]{:name=>"aurora-scheduler"}, File[/var/lib/aurora/scheduler]{:path=>"/var/lib/aurora/scheduler"}]')
      end

      it do
        should contain_file('/var/lib/aurora/scheduler')
          .with_ensure('directory')
          .with_mode('0644')
          .with_owner('aurora')
          .with_group('aurora')
      end

      it do
        should contain_file('/etc/sysconfig/aurora-scheduler')
          .with_ensure('present')
          .with_owner('aurora')
          .with_group('aurora')
          .with_mode('0644')
      end

      context 'scheduler params' do
        it do
          should contain_file('/etc/sysconfig/aurora-scheduler')
            .with_content(/GLOG_v=0/)
            .with_content(/LIBPROCESS_PORT=8083/)
            .with_content(/cluster_name='mesos'/)
            .with_content(/http_port=8081/)
            .with_content(/native_log_quorum_size='1'/)
            .with_content(/zk_endpoints=127\.0\.0\.1\:2181/)
            .with_content(/mesos_master_address='zk:\/\/127\.0\.0\.1:2181\/mesos'/)
            .with_content(/serverset_path='\/aurora\/scheduler'/)
            .with_content(/native_log_file_path='\/var\/lib\/aurora\/scheduler\/db'/)
            .with_content(/backup_dir='\/var\/lib\/aurora\/scheduler\/backups'/)
            .with_content(/thermos_executor_path='\/usr\/bin\/thermos_executor'/)
            .with_content(/thermos_executor_flags='--announcer-enable --announcer-ensemble 127\.0\.0\.1:2181'/)
            .with_content(/allowed_container_types='DOCKER,MESOS'/)
            .with_content(/vlog='INFO'/)
        end
      end
    end
  end
end
