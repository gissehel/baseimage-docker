#!/bin/bash
set -e
source /build/buildconfig
set -x

## Temporarily disable dpkg fsync to make building faster.
echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

## Enable Ubuntu Universe and Multiverse.
cp /build/sources.list /etc/apt/sources.list
apt-get update

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## Install HTTPS support for APT.
$minimal_apt_get_install apt-transport-https

## Temporary workaround for issue https://github.com/dotcloud/stackbrew/issues/52 (missing 40 packages in last ubuntu:12.04 image compared to previous ones)
$minimal_apt_get_install apt-utils bzip2 console-setup debconf-i18n dmsetup eject iputils-ping isc-dhcp-client isc-dhcp-common kbd keyboard-configuration less libapt-inst1.4 libdevmapper1.02.1 libexpat1 liblocale-gettext-perl libnewt0.52 libpopt0 libsqlite3-0 libtext-charwidth-perl libtext-iconv-perl libtext-wrapi18n-perl lsb-release mime-support net-tools netbase netcat-openbsd ntpdate python python2.7 rsyslog sudo ucf ureadahead vim-common vim-tiny whiptail xkb-data
## not working :  $minimal_apt_get_install resolvconf ubuntu-minimal

## Upgrade all packages.
apt-get dist-upgrade -y --no-install-recommends

## Fix locale.
$minimal_apt_get_install language-pack-en
locale-gen en_US
