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
# Simplified BSD License
#
# Copyright (c) 2009, Boxed Ice <hello@boxedice.com>
#     Copyright (c) 2010-2015, Datadog <info@datadoghq.com>
#     All rights reserved.
#
#     Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#                                                                  this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#                                                                         this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#     * Neither the name of Boxed Ice nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#     * Neither the name of Datadog nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# These options are required for all software definitions
name "datadog-agent"
# default_version "5.7.3"

# A software can specify more than one version that is available for install
# version("#{version}") { source url: "https://github.com/DataDog/dd-agent/archive/#{version}.tar.gz" }
source github: "mbeissinger/dd-agent-packaging"

# This is the path, inside the tarball, where the source resides
relative_path "dd-agent-packaging"

puts "#{project_dir}"

endpoint_env = 'NETSIL_DD_ENDPOINT'
api_env = 'DD_API_KEY'
default_endpoint = 'http://localhost:2001/'
default_api = 'netsil'

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  # make sure env has a default netsil dd endpoint
  if not env.key?(endpoint_env)
    env[endpoint_env] = default_endpoint
  end
  if not env.key?(api_env)
    env[api_env] = default_api
  end

  if linux?
    command "DD_API_KEY=#{env[api_env]} DD_URL=#{env[endpoint_env]} bash packaging/datadog-agent/source/install_agent.sh"
    # restart the agent
    command "sudo /etc/init.d/datadog-agent restart"
  end

  if osx?
    command "DD_API_KEY=#{env[api_env]} DD_URL=#{env[endpoint_env]} bash packaging/osx/install.sh"
    # restart the agent
    command "sudo /opt/datadog-agent/bin/datadog-agent restart >/dev/null"
  end

end
