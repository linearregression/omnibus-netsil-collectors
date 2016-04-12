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
default_version "5.7.3"
datadog_dir = "/opt/datadog-agent"

# A software can specify more than one version that is available for install
version("#{version}") { source url: "https://github.com/DataDog/dd-agent/archive/#{version}.tar.gz" }

# This is the path, inside the tarball, where the source resides
relative_path "dd-agent"

endpoint_env = 'NETSIL_DD_ENDPOINT'
default_endpoint = 'http://localhost:2001'

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  # make sure env has a default netsil dd endpoint
  if not env.key?(endpoint_env)
    env[endpoint_env] = default_endpoint
  end

  # Agent code
  mkdir  "#{datadog_dir}/agent/"
  copy 'checks.d', "#{datadog_dir}/agent/"
  copy 'checks', "#{datadog_dir}/agent/"
  copy 'dogstream', "#{datadog_dir}/agent/"
  copy 'resources', "#{datadog_dir}/agent/"
  copy 'utils', "#{datadog_dir}/agent/"
  command "cp *.py #{datadog_dir}/agent/"
  copy 'datadog-cert.pem', "#{datadog_dir}/agent/"

  mkdir "#{datadog_dir}/run/"


  if linux?
    # Configuration files
    mkdir '/etc/dd-agent'
    if ohai['platform_family'] == 'rhel'
      copy 'packaging/centos/datadog-agent.init', '/etc/rc.d/init.d/datadog-agent'
    elsif ohai['platform_family'] == 'debian'
      copy 'packaging/debian/datadog-agent.init', '/etc/init.d/datadog-agent'
      mkdir '/lib/systemd/system'
      copy 'packaging/debian/datadog-agent.service', '/lib/systemd/system/datadog-agent.service'
      copy 'packaging/debian/start_agent.sh', '/opt/datadog-agent/bin/start_agent.sh'
      command 'chmod 755 /opt/datadog-agent/bin/start_agent.sh'
    end
    # Use a supervisor conf with go-metro on 64-bit platforms only
    if ohai['kernel']['machine'] == 'x86_64'
      copy 'packaging/supervisor.conf', '/etc/dd-agent/supervisor.conf'
    else
      copy 'packaging/supervisor_32.conf', '/etc/dd-agent/supervisor.conf'
    end
    # copy over the example configuration file, but make the dd_url point to netsil's endpoint
    command "sed 's/dd_url: https:\/\/app.datadoghq.com\//dd_url: #{env[default_endpoint]}' datadog.conf.example > /etc/dd-agent/datadog.conf.example"
    #copy 'datadog.conf.example', '/etc/dd-agent/datadog.conf.example'
    copy 'conf.d', '/etc/dd-agent/'
    mkdir '/etc/dd-agent/checks.d/'
    command 'chmod 755 /etc/init.d/datadog-agent'
    touch '/usr/bin/dd-agent'

    # Remove the .pyc and .pyo files from the package and list them in a file
    # so that the prerm script knows which compiled files to remove
    command "echo '# DO NOT REMOVE/MODIFY - used by package removal tasks' > #{datadog_dir}/embedded/.py_compiled_files.txt"
    command "find #{datadog_dir}/embedded '(' -name '*.pyc' -o -name '*.pyo' ')' -type f -delete -print >> #{datadog_dir}/embedded/.py_compiled_files.txt"
  end

  if osx?
    env = {
        'PATH' => "#{datadog_dir}/embedded/bin/:#{env['PATH']}"
    }

    app_temp_dir = "#{datadog_dir}/agent/dist/Datadog Agent.app/Contents"
    app_temp_dir_escaped = "#{datadog_dir}/agent/dist/Datadog\\ Agent.app/Contents"
    pyside_build_dir =  "#{datadog_dir}/agent/build/bdist.macosx-10.5-intel/python2.7-standalone/app/collect/PySide"
    command_fix_shiboken = 'install_name_tool -change @rpath/libshiboken-python2.7.1.2.dylib'\
                      ' @executable_path/../Frameworks/libshiboken-python2.7.1.2.dylib '
    command_fix_pyside = 'install_name_tool -change @rpath/libpyside-python2.7.1.2.dylib'\
                      ' @executable_path/../Frameworks/libpyside-python2.7.1.2.dylib '

    # Command line tool
    copy 'packaging/osx/datadog-agent', "#{datadog_dir}/bin"
    command "chmod 755 #{datadog_dir}/bin/datadog-agent"

    # GUI
    copy 'packaging/datadog-agent/win32/install_files/guidata/images', "#{datadog_dir}/agent"
    copy 'win32/gui.py', "#{datadog_dir}/agent"
    copy 'win32/status.html', "#{datadog_dir}/agent"
    mkdir "#{datadog_dir}/agent/packaging"
    copy 'packaging/osx/app/*', "#{datadog_dir}/agent/packaging"

    command "cd #{datadog_dir}/agent && "\
            "#{datadog_dir}/embedded/bin/python #{datadog_dir}/agent/setup.py py2app"\
            ' && cd -', env: env
    # Time to patch the install, see py2app bug: (dependencies to system PySide)
    # https://bitbucket.org/ronaldoussoren/py2app/issue/143/resulting-app-mistakenly-looks-for-pyside
    copy "#{pyside_build_dir}/libshiboken-python2.7.1.2.dylib", "#{app_temp_dir}/Frameworks/libshiboken-python2.7.1.2.dylib"
    copy "#{pyside_build_dir}/libpyside-python2.7.1.2.dylib", "#{app_temp_dir}/Frameworks/libpyside-python2.7.1.2.dylib"

    command "chmod a+x #{app_temp_dir_escaped}/Frameworks/{libpyside,libshiboken}-python2.7.1.2.dylib"
    command "#{command_fix_shiboken} #{app_temp_dir_escaped}/Frameworks/libpyside-python2.7.1.2.dylib"
    command 'install_name_tool -change /usr/local/lib/QtCore.framework/Versions/4/QtCore '\
            '@executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore '\
            "#{app_temp_dir_escaped}/Frameworks/libpyside-python2.7.1.2.dylib"
    command "#{command_fix_shiboken} #{app_temp_dir_escaped}/Resources/lib/python2.7/lib-dynload/PySide/QtCore.so"
    command "#{command_fix_shiboken} #{app_temp_dir_escaped}/Resources/lib/python2.7/lib-dynload/PySide/QtGui.so"
    command "#{command_fix_pyside} #{app_temp_dir_escaped}/Resources/lib/python2.7/lib-dynload/PySide/QtCore.so"
    command "#{command_fix_pyside} #{app_temp_dir_escaped}/Resources/lib/python2.7/lib-dynload/PySide/QtGui.so"

    # And finally
    command "cp -Rf #{datadog_dir}/agent/dist/Datadog\\ Agent.app #{datadog_dir}"

    # Clean GUI related things
    %w(build dist images gui.py status.html packaging Datadog_Agent.egg-info).each do |file|
      delete "#{datadog_dir}/agent/#{file}"
    end
    %w(py2app macholib modulegraph altgraph).each do |package|
      command "yes | #{datadog_dir}/embedded/bin/pip uninstall #{package}"
    end
    %w(pyside guidata spyderlib).each do |dependency_name|
      # Installed with `python setup.py install`, needs to be uninstalled manually
      command "cat #{datadog_dir}/embedded/#{dependency_name}-files.txt | xargs rm -rf \"{}\""
      delete "#{datadog_dir}/embedded/#{dependency_name}-files.txt"
    end

    # conf
    mkdir "#{datadog_dir}/etc"
    copy "packaging/osx/supervisor.conf", "#{datadog_dir}/etc/supervisor.conf"
    # copy over the example configuration file, but make the dd_url point to netsil's endpoint
    command "sed 's/dd_url: https:\/\/app.datadoghq.com\//dd_url: #{env[endpoint_env]}' datadog.conf.example > #{datadog_dir}/etc/datadog.conf.example"
    # copy 'datadog.conf.example', "#{datadog_dir}/etc/datadog.conf.example"
    command "cp -R conf.d #{datadog_dir}/etc/"
    copy 'packaging/osx/com.datadoghq.Agent.plist.example', "#{datadog_dir}/etc/"
  end

  # The file below is touched by software builds that don't put anything in the installation
  # directory (libgcc right now) so that the git_cache gets updated let's remove it from the
  # final package
  delete "#{datadog_dir}/uselessfile"
end
