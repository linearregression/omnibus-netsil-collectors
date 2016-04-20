FROM ubuntu:14.04

# Dependencies
RUN apt-get update
RUN apt-get install -y libssl-dev \ 
        libreadline-dev \ 
        zlib1g-dev \ 
        git \ 
        make \ 
        wget \
        autoconf \
        bison \
        apt-transport-https \
        rbenv \
        g++ \
        unzip \
        fakeroot 

RUN apt-get clean

RUN git config --global user.email kevin@netsil.com && git config --global user.name luhkevin

# Ruby stuff
# We should eventually clone rbenv, as we do in the rpm build
#RUN git clone git://github.com/rbenv/rbenv.git .rbenv
RUN echo "export PATH=$HOME/.rbenv/bin:$PATH" >> ~/.bashrc 
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build 
RUN rbenv install 2.3.0-dev && rbenv rehash

# Should we run these ONLY when developing this image? Comment out after the image is stable?
WORKDIR /root
RUN mkdir -p /root/omnibus-netsil-collectors
COPY Gemfile /root/omnibus-netsil-collectors/

# Copy in bake script
COPY bake-gems.sh /root/bake-gems.sh
RUN bash /root/bake-gems.sh

# Get rid of the Gemfile.lock so if we have updates to the base Gemfile, we can install them
RUN rm /root/omnibus-netsil-collectors/Gemfile.lock

# Copy in omnibus build script
COPY build-omnibus-deb.sh /root/build-omnibus-deb.sh
RUN chmod +x /root/build-omnibus-deb.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/root/build-omnibus-deb.sh"]

