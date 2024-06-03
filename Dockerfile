FROM ubuntu:22.04
LABEL maintainer="Chef Software, Inc. <docker@chef.io>"

ARG CHANNEL=stable
ARG VERSION=24.4.1064
ENV DEBIAN_FRONTEND=noninteractive \
    GEM_HOME=/root/.chefdk/gem/ruby/3.0.0 \
    PATH=/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:/root/.chefdk/gem/ruby/3.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Run the entire container with the default locale to be en_US.UTF-8
RUN apt-get update && \
    apt-get install -y locales=2.35-* && \ 
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y gcc=4:11.2.* git=1:2.34.* graphviz=2.42.* make=4.3-* rsync=3.2.* ssh=1:8.9p1-* vim-tiny=2:8.2.* wget=1.21.* && \ 
    ln -s /usr/bin/vi /usr/bin/vim && \
    wget --content-disposition "http://packages.chef.io/files/${CHANNEL}/chef-workstation/${VERSION}/ubuntu/18.04/chef-workstation_${VERSION}-1_amd64.deb" -O /tmp/chef-workstation.deb && \
    dpkg -i /tmp/chef-workstation.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*log /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old

CMD ["/bin/bash"]
