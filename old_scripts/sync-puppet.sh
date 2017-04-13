#!/bin/sh
#
mkdir -p /var/www/html/puppetlabs/6/deps/x86_64/
mkdir -p /var/www/html/puppetlabs/6/products/x86_64/

/usr/bin/rsync -iavrt rsync://yum.puppetlabs.com/packages/yum/el/6/dependencies/x86_64/ /var/www/html/puppetlabs/6/deps/x86_64/
/usr/bin/rsync -iavrt rsync://yum.puppetlabs.com/packages/yum/el/6/products/x86_64/ /var/www/html/puppetlabs/6/products/x86_64/

/usr/bin/createrepo /var/www/html/puppetlabs/6/deps/x86_64/
/usr/bin/createrepo /var/www/html/puppetlabs/6/products/x86_64/

