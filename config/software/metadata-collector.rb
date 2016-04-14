#
# Copyright Netsil (c) 2016
#
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
#

name "metadata-collector"

# A software can specify more than one version that is available for install
# version("#{version}") { source url: "https://github.com/DataDog/dd-agent/archive/#{version}.tar.gz" }
source url: "https://s3.amazonaws.com/bin.netsil.io/metadata-collector/metadata-collector.tar.gz",
       md5: "b568faf1f0dbf18e793fe790d0b5c57b"

# This is the path, inside the tarball, where the source resides
relative_path "."

dependency 'python'

puts "#{project_dir}"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  if linux?
    mkdir "#{install_dir}/metadata-collector/"
    copy 'metadata_collector.py', "#{install_dir}/metadata-collector/"
    copy 'docker_metadata.py', "#{install_dir}/metadata-collector/"
    copy 'util.py', "#{install_dir}/metadata-collector/"
    copy 'requirements.txt', "#{install_dir}/metadata-collector/"

    command "#{install_dir}/embedded/bin/pip install -I --build #{project_dir} -r #{install_dir}/metadata-collector/requirements.txt"

    # restart the agent
    #command "sudo /etc/init.d/datadog-agent restart"
  end

  if osx?
    # command "DD_API_KEY=#{env[api_env]} DD_URL=#{env[endpoint_env]} bash packaging/osx/install.sh"
    # restart the agent
    # command "sudo /opt/datadog-agent/bin/datadog-agent restart >/dev/null"
  end

end
