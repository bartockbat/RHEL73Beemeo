#
# To use it, build your image:
# docker build -t bleemeo/bleemeo-agent .
# docker run --name="bleemeo-agent" --net=host --pid=host -v /tmp/telegraf:/etc/telegraf/telegraf.d/bleemeo-generated.conf -v /var/lib/bleemeo:/var/lib/bleemeo -v /var/run/docker.sock:/var/run/docker.sock bleemeo/bleemeo-agent
#

FROM registry.access.redhat.com/rhel7

MAINTAINER Lionel Porcheron <lionel.porcheron@bleemeo.com>

LABEL name="rhel73/bleemeo" \
      vendor="Bleemeo" \
      version="OSS" \
      release="1" \
      summary="Bleemeo's Super Secret Application" \
description="Starter app will do ....."

#Copy the help file - atomic help - satisfy the scanner requirements
COPY help.1 /
RUN mkdir /licenses
COPY license /licenses

### Add necessary Red Hat repos here
RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms \
### Add your package needs here
    INSTALL_PKGS="golang-github-cpuguy83-go-md2man" && \
    yum -y update-minimal --disablerepo "*" --enablerepo rhel-7-server-rpms --setopt=tsflags=nodocs \
      --security --sec-severity=Important --sec-severity=Critical && \
yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs ${INSTALL_PKGS} \
yum -y install yum-plugin-post-transaction-actions
RUN yum -y install wget

#Dependencies for Bleemeo - needs telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf-1.3.4-1.x86_64.rpm
RUN yum -y install telegraf-1.3.4-1.x86_64.rpm

COPY bleemeo.repo  /etc/yum.repos.d/bleemeo.repo

#RUN   yum -y update-minimal --setopt=tsflags=nodocs \
#--security --sec-severity=Important --sec-severity=Critical

#Adding EPEL Repo for software 
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum -y install bleemeo-agent-telegraf 
RUN yum -y install bleemeo-agent
#RUN mkdir -p /etc/telegraf/telegraf.d/ && touch /etc/telegraf/telegraf.d/bleemeo-generated.conf
#RUN chown bleemeo /etc/telegraf/telegraf.d/bleemeo-generated.conf
#ADD 60-bleemeo.conf /etc/bleemeo/agent.conf.d/

#USER bleemeo
#CMD ["/usr/bin/bleemeo-agent", "--yes-run-as-root"]
