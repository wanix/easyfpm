#!/bin/sh
##############################################################################
## Script  : (easyfpm) pre-delete.sh
## Author  : Erwan SEITE
## Aim     : pre-delete for package
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
##############################################################################
# This script must be in posix format
# It will be launched by the link /bin/sh on the targeted OS
##############################################################################
# Parameters (launched by installation process) : 
#  If Debian based OS
#    $1=
#  If Redhat based OS
#    $1=0 if deletion
#    $1=1 if upgrade
##############################################################################
# NB : This script can use fpm KEY=VALUE mode with template-scripts active
#      in your easyfpm conf
##############################################################################
# Return Code : 
#   0 if OK
#   1 if Error
##############################################################################
exit 0
