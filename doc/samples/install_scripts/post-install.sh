#!/bin/sh
#Sample post-install.sh script for easyfpm : https://github.com/wanix/easyfpm.git
#Usage for deb : https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html
#Usage for rpm : http://www.rpm.org/max-rpm-snapshot/s1-rpm-inside-scripts.html

myOperation=${1}

case ${myOperation} in
  1)                #Install RedHat
                     exit 0;;
  2)                 #Upgrade RedHat
                     exit 0;;
  configure)         #Debian:
                     #postinst configure <most-recently-configured-version>
                     exit 0;;
  abort-upgrade)     #Debian:
                     #old-postinst abort-upgrade <new-version>
                     exit 0;;
  abort-remove)      #Debian:
                     #postinst abort-remove
                     #or conflictor's-postinst abort-remove in-favour <package> <new-version>
                     exit 0;;
  abort-deconfigure) #Debian
                     #deconfigured's-postinst abort-deconfigure in-favour <failed-install-package> <version> [removing <conflicting-package> <version>]
                      exit 0;;
  \?)                 #Unknown
                      exit 1;;
  *)                  exit 1;;
esac
exit 0
