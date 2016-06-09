require 'spec_helper'

describe 'aurora' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          version: '0.10.0',
          enable: true,
          configure_repo: false,
          scheduler_options: {
            'libmesos_log_verbosity' => 0,
            'libprocess_port' => '8083',
            'java_opts' => ['-server', "-Djava.library.path='/usr/lib;/usr/lib64'" ],
            'cluster_name' => 'mesos',
            'http_port' => '8081',
            'quorum_size' => 1,
            'zookeeper' => '127.0.0.1:2181',
            'zookeeper_mesos_path' => 'mesos',
            'zookeeper_aurora_path' => 'aurora',
            'thermos_executor' => '/usr/bin/thermos_executor',
            'thermos_executor_flags' => [ '--announcer-enable', '--announcer-ensemble 127.0.0.1:2181' ],
            'allowed_container_types' => %w(DOCKER MESOS),
          }
        }
      end

      it { should compile }
      it { should contain_class('aurora') }
      it { should contain_class('aurora::repo') }

      context 'with an invalid master parameter' do
        let(:params) { super().merge(master: 'test') }
        it { should raise_error(Puppet::Error, /Unknown type of boolean/) }
      end

      context 'scheduler options' do
        $expected_string_params = %w(libmesos_log_verbosity libprocess_port cluster_name zookeeper zookeeper_mesos_path zookeeper_aurora_path)
        $expected_string_params.each do |scheduler_param|
          context "with an invalid #{scheduler_param}  parameter" do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => true)
              params
            end
            it { should raise_error(Puppet::Error, /is not a string/) }
          end
        end

        $expected_string_params.each do |scheduler_param|
          context "with an invalid #{scheduler_param}  parameter"  do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => ['test'])
              params
            end
            it { should raise_error(Puppet::Error, /is not a string/) }
          end
        end

        $expected_array_params = %w(java_opts allowed_container_types thermos_executor_flags extra_scheduler_args)
        $expected_array_params.each do |scheduler_param|
          context "with an invalid #{scheduler_param}  parameter" do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => 'test')
              params
            end
            it { should raise_error(Puppet::Error, /is not an Array/) }
          end
        end

        $expected_array_params.each do |scheduler_param|
          context "with an invalid  #{scheduler_param}  parameter" do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => true)
              params
            end
            it { should raise_error(Puppet::Error, /is not an Array/) }
          end
        end

        $expected_abs_path_params = %w(aurora_home thermos_executor_path)
        $expected_abs_path_params.each do |scheduler_param|
          context "with an invalid  #{scheduler_param}  parameter" do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => 'test')
              params
            end
            it { should raise_error(Puppet::Error, /is not an absolute path/) }
          end
        end

        $expected_ints = %w(http_port quorum_size)
        $expected_ints.each do |scheduler_param|
          context "with an invalid  #{scheduler_param}  parameter" do
            let (:params) do
              params = super()
              params[:scheduler_options].merge!(scheduler_param => 'test')
              params
            end
            it { (should(raise_error(Puppet::Error, /Expected first argument to be an Integer or Array, got #{scheduler_param.class}/)) || (should(raise_error(Puppet::Error, /Expected element at array position 0 to be an Integer, got #{scheduler_param.class}/)))) }
          end
        end
      end
    end
  end
end
