FROM fedora:41
LABEL maintainer="Kevin Niederwanger"
LABEL name="skalador/fedora41-ansible"
LABEL vendor=""
LABEL version="41"
LABEL release="v0.1.0"
LABEL summary="Fedora 41 Podman image for Ansible testing."
LABEL description="Fedora 41 Podman image for Ansible testing."

COPY LICENSE /licenses

ENV pip_packages "ansible"

USER root

RUN dnf -y update && dnf clean all

# Enable systemd.
RUN dnf -y install systemd && dnf clean all && \
  (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install pip and other requirements.
RUN dnf makecache \
  && dnf -y install \
    python3-pip \
    sudo \
    which \
    python3-dnf \
    python3-libdnf5 \
  && dnf clean all

# Install Ansible via Pip.
RUN pip3 install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
COPY ansible-hosts /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/usr/sbin/init"]
