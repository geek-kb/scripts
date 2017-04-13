#!/bin/sh
#
# reposync
#

BASEDIR=/var/www/html
mkdir -p $BASEDIR 
cd $BASEDIR

reposync -n -r epel
repomanage -o -c epel | xargs rm -fv
createrepo epel
