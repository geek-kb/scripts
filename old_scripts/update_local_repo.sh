#!/bin/bash

## Puppetlabs6 Repo
mkdir -p /var/www/html/repos/puppetlabs/6/deps/x86_64/
mkdir -p /var/www/html/repos/puppetlabs/6/products/x86_64/

/usr/bin/rsync -iavrt rsync://yum.puppetlabs.com/packages/yum/el/6/dependencies/x86_64/ /var/www/html/repos/puppetlabs/6/deps/x86_64/
/usr/bin/rsync -iavrt rsync://yum.puppetlabs.com/packages/yum/el/6/products/x86_64/ /var/www/html/repos/puppetlabs/6/products/x86_64/

/usr/bin/createrepo /var/www/html/repos/puppetlabs/6/deps/x86_64/
/usr/bin/createrepo /var/www/html/repos/puppetlabs/6/products/x86_64/

## EPEL Repo
mkdir -p /var/www/html/repos/epel/6/x86_64
/usr/bin/rsync -iavrt rsync://mirror.pnl.gov/epel/6/x86_64/ /var/www/html/repos/epel/6/x86_64
/usr/bin/createrepo /var/www/html/repos/epel/6/x86_64

## Centos 6
mkdir -p /var/www/html/repos/centos/6.6/updates/
mkdir -p /var/www/html/repos/centos/6.6/os/

/usr/bin/rsync -iavt rsync://mirror.hostduplex.com/centos/6.6/updates/x86_64 /var/www/html/repos/centos/6.6/updates/
/usr/bin/rsync -iavt rsync://mirror.hostduplex.com/centos/6.6/os/x86_64 /var/www/html/repos/centos/6.6/os/

/usr/bin/createrepo /var/www/html/repos/centos/6.6/updates/
/usr/bin/createrepo /var/www/html/repos/centos/6.6/os/

