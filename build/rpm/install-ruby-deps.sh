#!/bin/bash

source ~/.bashrc

git clone git://github.com/rbenv/rbenv.git ~/.rbenv

echo "export PATH=$HOME/.rbenv/bin:$PATH" >> ~/.bashrc

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

~/.rbenv/bin/rbenv install 2.3.0-dev
