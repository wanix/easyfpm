#!/bin/sh
#Sample pre-delete.sh script for easyfpm : https://github.com/wanix/easyfpm.git
#Usage for deb : https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html
#Usage for rpm : http://www.rpm.org/max-rpm-snapshot/s1-rpm-inside-scripts.html

myOperation=${1}

case ${myOperation} in
  0)              #Uninstall RedHat
                  exit 0;;
  1)              #Upgrade RedHat
                  exit 0;;
  remove)         #Debian:
                  #prerm remove
                  #or conflictor's-prerm remove in-favour <package> <new-version>
                  exit 0;;
  upgrade)        #Debian:
                  #old-prerm upgrade <new-version>
                  exit 0;;
  deconfigure)    #Debian:
                  #deconfigured's-prerm deconfigure in-favour <package-being-installed> <version> [removing <conflicting-package> <version>]
                  exit 0;;
  failed-upgrade) #Debian:
                  #new-prerm failed-upgrade <old-version>
  \?)             #Unknown
                  exit 1;;
  *)              exit 1;;
esac
exit 0
