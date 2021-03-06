#!/bin/sh
##############################################################################
## Script  : (easyfpm) pre-install.sh
## Author  : Erwan SEITE
## Aim     : pre-install for package
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
##############################################################################
# This script must be in posix format
# It will be launched by the link /bin/sh on the targeted OS
##############################################################################
# Parameters (launched by installation process) : 
#  If Debian based OS
#    $1=install if install
#    $1=upgrade if upgrade
#    $2=<old version> if upgrade
#  If Redhat based OS
#    $1=1 if install
#    $1=2 if upgrade
##############################################################################
# NB : This script can use fpm KEY=VALUE mode with template-scripts active
#      in your easyfpm conf
##############################################################################
# Return Code : 
#   0 if OK
#   1 if Error
##############################################################################
exit 0
