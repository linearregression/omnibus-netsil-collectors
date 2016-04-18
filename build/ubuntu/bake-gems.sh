#!/bin/bash
source ~/.bashrc

set -x

cd /root/omnibus-netsil-collectors

# Setup rbenv stuff
rbenv local 2.3.0-dev
eval "$(rbenv init -)"
rbenv which gem
gem install --no-ri --no-rdoc bundler
rbenv rehash
rbenv which bundler

# Install gems with bundler
bundle install --binstubs

# Remove omnibus-netsil-collectors so we can use our dev verison
rm -rf /root/omnibus-netsil-collectors/*
