#!/bin/sh
#Sample post-delete.sh script for easyfpm : https://github.com/wanix/easyfpm.git
#Usage for deb : https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html
#Usage for rpm : http://www.rpm.org/max-rpm-snapshot/s1-rpm-inside-scripts.html

myOperation=${1}

case ${myOperation} in
  0)              #Uninstall RedHat
                  exit 0;;
  1)              #Upgrade RedHat
                  exit 0;;
  remove)         #Debian:
                  #postrm remove
                  exit 0;;
  purge)          #Debian:
                  #postrm purge
                  exit 0;;
  upgrade)        #Debian:
                  #old-postrm upgrade <new-version>
                  exit 0;;
  disappear)      #Debian:
                  #disappearer's-postrm disappear <overwriter> <overwriter-version>
                  exit 0;;
  failed-upgrade) #Debian:
                  #new-postrm failed-upgrade <old-version>
                  exit 0;;
  abort-install)  #Debian:
                  #new-postrm abort-install
                  # or new-postrm abort-install <old-version>
                  exit 0;;
  abort-upgrade)  #Debian:
                  #new-postrm abort-upgrade <old-version>
                  exit 0;;
  \?)             #Unknown
                  exit 1;;
  *)              exit 1;;
esac
exit 0
