#!/bin/bash
set -x

source ~/.bashrc 

cd /root/omnibus-netsil-collectors

mkdir -p /root/omnibus-netsil-collectors/pkg

# Setup rbenv stuff
rbenv local 2.3.0-dev
eval "$(rbenv init -)"

# Install gems with bundler
bundle update --source omnibus-software
bundle install --binstubs

# Build omnibus
ls
./bin/omnibus build netsil

