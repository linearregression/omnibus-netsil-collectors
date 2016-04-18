FROM ubuntu:14.04

# Dependencies
RUN apt-get update && \ 
    apt-get install -y libssl-dev libreadline-dev zlib1g-dev git make wget autoconf bison vim apt-transport-https rbenv g++ unzip fakeroot

RUN git config --global user.email kevin@netsil.com && git config --global user.name luhkevin

# Ruby stuff
RUN echo "export PATH=$HOME/.rbenv/bin:$PATH" >> ~/.bashrc 
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build 
RUN rbenv install 2.3.0-dev && rbenv rehash

# Clone omnibus-netsil-collectors *just* to get the Gemfile, so we can bake in all the gems
WORKDIR /root

# Should we run these ONLY when developing this image? Comment out after the image is stable?
RUN mkdir -p /root/omnibus-netsil-collectors
COPY Gemfile /root/omnibus-netsil-collectors/

#RUN git clone https://github.com/netsil/omnibus-netsil-collectors

# Copy in bake script
COPY bake-gems.sh /root/bake-gems.sh
RUN bash /root/bake-gems.sh

# Copy in omnibus build script
COPY build-omnibus-ubuntu.sh /root/build-omnibus-ubuntu.sh
RUN chmod +x /root/build-omnibus-ubuntu.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/root/build-omnibus-ubuntu.sh"]

#RUN /bin/bash -c "rbenv local 2.3.0-dev \ 
#    && eval '$(rbenv init -)' \
#    && gem install bundler \
#    && rbenv rehash \
#    && bundle install --binstubs \
#    && ./bin/omnibus build netsil"

