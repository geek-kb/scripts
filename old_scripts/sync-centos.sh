#!/bin/sh
#
# reposync
#

BASEDIR=/var/www/html
mkdir -p $BASEDIR 
cd $BASEDIR

reposync -n -r updates
repomanage -o -c updates | xargs rm -fv
createrepo updates

reposync -n -r base --downloadcomps
repomanage -o -c base | xargs rm -fv
createrepo base -g comps.xml
