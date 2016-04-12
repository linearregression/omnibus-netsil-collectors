#
# Copyright 2016 Netsil
#
# All Rights Reserved.
#

name "netsil"
maintainer "Netsil"
homepage "https://netsil.com"

# Defaults to C:/netsil on Windows
# and /opt/netsil on all other platforms
install_dir "/opt/netsil"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# netsil dependencies/components
# ------------------------------------
# OS specific DSLs and dependencies
# ------------------------------------

# Linux
if linux?
  # Debian
  if debian?
    extra_package_file '/lib/systemd/system/datadog-agent.service'
  end

  # SysVInit service file
  if redhat?
    extra_package_file '/etc/rc.d/init.d/datadog-agent'
  else
    extra_package_file '/etc/init.d/datadog-agent'
  end

  # Supervisord config file for the agent
  extra_package_file '/etc/dd-agent/supervisor.conf'

  # Example configuration files for the agent and the checks
  extra_package_file '/etc/dd-agent/datadog.conf.example'
  extra_package_file '/etc/dd-agent/conf.d'

  # Custom checks directory
  extra_package_file '/etc/dd-agent/checks.d'

  # Just a dummy file that needs to be in the RPM package list if we don't want it to be removed
  # during RPM upgrades. (the old files from the RPM file listthat are not in the new RPM file
  # list will get removed, that's why we need this one here)
  extra_package_file '/usr/bin/dd-agent'

  # Linux-specific dependencies
  dependency "procps-ng"
  dependency "sysstat"
end

# Mac and Windows
if osx? or windows?
  dependency "gui"
end

# ------------------------------------
# Dependencies
# ------------------------------------

# creates required build directories
dependency "preparation"

# Agent dependencies
dependency "boto"
dependency "docker-py"
dependency "ntplib"
dependency "pycrypto"
dependency "pyopenssl"
dependency "pyyaml"
dependency "simplejson"
dependency "supervisor"
dependency "tornado"
dependency "uptime"
dependency "uuid"
dependency "zlib"

# Check dependencies
dependency "adodbapi"
dependency "dnspython"
dependency "httplib2"
dependency "kafka-python"
dependency "kazoo"
dependency "paramiko"
dependency "pg8000"
dependency "psutil"
dependency "psycopg2"
dependency "pymongo"
dependency "pymysql"
dependency "pysnmp"
dependency "python-gearman"
dependency "python-memcached"
dependency "python-redis"
dependency "python-rrdtool"
dependency "pyvmomi"
dependency "requests"
dependency "snakebite"

# Additional software
dependency "datadogpy"

# datadog-gohai and datadog-metro are built last before datadog-agent since they should always
# be rebuilt (if put above, they would dirty the cache of the dependencies below
# and trigger a useless rebuild of many packages)
dependency "datadog-gohai"
if linux? and ohai['kernel']['machine'] == 'x86_64'
  dependency "datadog-metro"
end

# Datadog agent
dependency "datadog-agent"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
