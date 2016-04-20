#!/bin/bash

# This script tests *installation*, but not the actual runtime of the package. 
# E.g. it just makes sure everything is put in the right place. 
# The collectors will be started in the install_netsil_collectors.sh script

cd /root/pkg

most_recent_deb=$(ls *.deb | tail -n 1)

sudo dpkg -i ${most_recent_deb}

# Check that everything's installed
# We check a subset, otherwise the printout would be huge
tree /opt/netsil/collectors/traffic-collector
tree /opt/netsil/collectors/metadata-collector
tree /opt/netsil/collectors/conf.d
tree -L 1 /opt/netsil/collectors

cat /opt/netsil/collectors/version-manifest.txt
