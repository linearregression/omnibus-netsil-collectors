#!/bin/bash
set -x

cd /root/omnibus-netsil-collectors

# Setup rbenv stuff
rbenv local 2.3.0-dev
eval "$(rbenv init -)"

# Install gems with bundler
bundle install --binstubs

# Build omnibus
./bin/omnibus build netsil

