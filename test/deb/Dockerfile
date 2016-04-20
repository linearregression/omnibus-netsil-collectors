FROM ubuntu:14.04

RUN apt-get update && apt-get -y install tree

COPY install-collector-deb.sh /root/install-collector-deb.sh
RUN chmod +x /root/install-collector-deb.sh

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/root/install-collector-deb.sh"]

