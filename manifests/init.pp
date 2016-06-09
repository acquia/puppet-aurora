# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class aurora (
  $enable = true,
  $version = '0.10.0',
  $master = false,
  $owner = 'aurora',
  $group = 'aurora',
  $configure_repo = false,
  $repo_url = 'http://www.apache.org/dist/aurora/',
  $repo_key = undef,
  $observer_port = 1338,
  $scheduler_options = {
    'libmesos_log_verbosity'     => 0,
    'libprocess_port'            => '8083',
    'libprocess_ip'              => '127.0.0.1',
    'java_opts'                  => [
                                    # Uses server-level GC optimizations, as this is a server.
                                    '-server',
                                    # Location of libmesos-XXXX.so / libmesos-XXXX.dylib
                                    "-Djava.library.path='/usr/lib;/usr/lib64'",
                                  ],
    'cluster_name'               => 'mesos',
    'http_port'                  => '8081',
    'quorum_size'                => 1,
    'zookeeper'                  => '127.0.0.1:2181',
    'zookeeper_mesos_path'       => 'mesos',
    'zookeeper_aurora_path'      => 'aurora',
    'aurora_home'                => '/var/lib/aurora',
    'thermos_executor_path'      => '/usr/bin/thermos_executor',
    'thermos_executor_flags'     => [
                                    '--announcer-enable',
                                    '--announcer-ensemble 127.0.0.1:2181',
                                  ],
    'allowed_container_types'    => ['DOCKER','MESOS'],
    'extra_scheduler_args'       => []
  }
) {
  if $scheduler_options {
    if $scheduler_options['libmesos_log_verbosity'] {
      validate_string($scheduler_options['libmesos_log_verbosity'])
    }
    if $scheduler_options['libprocess_port'] {
      validate_string($scheduler_options['libprocess_port'])
    }
    if $scheduler_options['libprocess_ip'] {
      validate_string($scheduler_options['libprocess_ip'])
    }
    if $scheduler_options['java_opts'] {
      validate_array($scheduler_options['java_opts'])
    }
    if $scheduler_options['cluster_name'] {
      validate_string($scheduler_options['cluster_name'])
    }
    if $scheduler_options['http_port'] {
      validate_integer($scheduler_options['http_port'])
    }
    if $scheduler_options['quorum_size'] {
      validate_integer($scheduler_options['quorum_size'])
    }
    if $scheduler_options['zookeeper'] {
      validate_string($scheduler_options['zookeeper'])
    }
    if $scheduler_options['zookeeper_mesos_path'] {
      validate_string($scheduler_options['zookeeper_mesos_path'])
    }
    if $scheduler_options['zookeeper_aurora_path'] {
      validate_string($scheduler_options['zookeeper_aurora_path'])
    }
    if $scheduler_options['aurora_home'] {
      validate_absolute_path($scheduler_options['aurora_home'])
    }
    if $scheduler_options['thermos_executor_path'] {
      validate_absolute_path($scheduler_options['thermos_executor_path'])
    }
    if $scheduler_options['thermos_executor_flags'] {
      validate_array($scheduler_options['thermos_executor_flags'])
    }
    if $scheduler_options['allowed_container_types'] {
      validate_array($scheduler_options['allowed_container_types'])
    }
    if $scheduler_options['extra_scheduler_args'] {
      validate_array($scheduler_options['extra_scheduler_args'])
    }
  }

  validate_string($owner)
  validate_string($group)
  validate_string($repo_key)
  validate_string($repo_url)
  validate_integer($observer_port)

  contain aurora::repo
  contain aurora::install
  contain aurora::service

  Class['aurora::repo'] ->
  Class['aurora::install'] ->
  Class['aurora::service']
}
