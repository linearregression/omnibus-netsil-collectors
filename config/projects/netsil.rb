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

# creates required build directories
dependency "preparation"

# Pip
dependency "pip"

# Datadog agent
dependency "datadog-agent"

# traffic-collector (rpcapd)
dependency "traffic-collector"

# metadata-collector 
dependency "metadata-collector"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
