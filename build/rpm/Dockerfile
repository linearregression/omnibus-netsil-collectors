FROM centos:7

# Dependencies
RUN yum update -y; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum -y install openssl openssl-devel readline-devel zlib-devel git make wget autoconf bison vim gcc-c++ unzip libtool libtool-ltdl libtool-ltdl-devel; yum clean all
RUN yum -y install ruby fakeroot patch rpm-build

RUN git config --global user.email kevin@netsil.com && git config --global user.name luhkevin

# Ruby stuff, install rbenv, etc...
COPY install-ruby-deps.sh /root/install-ruby-deps.sh
RUN bash /root/install-ruby-deps.sh

# Should we run these ONLY when developing this image? Comment out after the image is stable?
WORKDIR /root
RUN mkdir -p /root/omnibus-netsil-collectors
COPY Gemfile /root/omnibus-netsil-collectors/

# Copy in bake script
COPY bake-gems.sh /root/bake-gems.sh
RUN bash /root/bake-gems.sh

# Copy in omnibus build script
COPY build-omnibus-rpm.sh /root/build-omnibus-rpm.sh
RUN chmod +x /root/build-omnibus-rpm.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/root/build-omnibus-rpm.sh"]

#RUN /bin/bash -c "rbenv local 2.3.0-dev \ 
#    && eval '$(rbenv init -)' \
#    && gem install bundler \
#    && rbenv rehash \
#    && bundle install --binstubs \
#    && ./bin/omnibus build netsil"

