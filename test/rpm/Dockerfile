FROM centos:7

RUN yum -y install tree

COPY install-collector-rpm.sh /root/install-collector-rpm.sh
RUN chmod +x /root/install-collector-rpm.sh

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/root/install-collector-rpm.sh"]

