FROM centos:7
MAINTAINER The CentOS Project <cloud-ops@centos.org>
LABEL Vendor="CentOS" \
      License=GPLv2 \
      Version=2.4.6-40

ADD shibboleth.repo /etc/yum.repos.d/shibboleth.repo

RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install httpd mod_ssh openssh java-1.8.0 && \
    yum -y install shibboleth.x86_64 && \
    yum clean all

WORKDIR /tmp

RUN yum install -y unzip && \
curl https://shibboleth.net/downloads/PGP_KEYS 2>/dev/null | gpg --import 
RUN curl http://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip > xmlsectool.zip && \
curl http://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip.asc > xmlsectool.zip.asc && \
gpg --verify xmlsectool.zip.asc xmlsectool.zip 
RUN unzip xmlsectool.zip && \
mv xmlsectool-2.0.0 /opt/xmlsectool && \
rm -f xmlsectool.zip xmlsectool.zip.asc 


EXPOSE 80 443

# Simple startup script to avoid some issues observed with container restart
ADD run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh"]