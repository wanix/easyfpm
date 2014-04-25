#!/bin/sh
#Sample pre-install.sh script for easyfpm : https://github.com/wanix/easyfpm.git
#Usage for deb : https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html
#Usage for rpm : http://www.rpm.org/max-rpm-snapshot/s1-rpm-inside-scripts.html

myOperation=${1}

case ${myOperation} in
  1)             #Install RedHat
                 exit 0;;
  2)             #Upgrade RedHat
                 exit 0;;
  install)       #Debian:
                 #new-preinst install
                 #or new-preinst install <old-version>
                 exit 0;;
  upgrade)       #Debian:
                 #new-preinst upgrade <old-version>
                 exit 0;;
  abort-upgrade) #Debian:
                 #old-preinst abort-upgrade <new-version>
                 exit 0;;
  \?)            #Unknown
                 exit 1;;
  *)             exit 1;;
esac
exit 0
