[![Gem](https://img.shields.io/gem/dtv/easyfpm.svg)]()
[![Gem](https://img.shields.io/gem/v/easyfpm.svg)]()
[![GitHub tag](https://img.shields.io/github/tag/wanix/easyfpm.svg?maxAge=2592000)]()

# easyfpm #

Methods and scripts for those who want to use fpm to make scripts packages

The aim of easyfpm is to facilitate the work of administrators and permit to deliver their scripts as packages.

## help of the script ##

this is given by --help parameter

``` text
Usage easyfpm [options]
        --config-file [string]       Configuration file's path
                                      (can be declared multiple times, declarative order is priority order)
        --label [list by comma]      Labels to work with
                                      (can be declared multiple times)
        --pkg-name [string]          Package name
        --pkg-type [string]          Package type
        --pkg-version [string]       Package version, example 1.0
        --pkg-src-dir [string]       Package source dir
        --pkg-mapping [string]       Package install map file
        --pkg-prefix [string]        Package installation prefix
        --pkg-output-dir [string]    Destination dir for packages
        --pkg-description [string]   Package description
        --pkg-arch [string]          Package architecture
        --pkg-content [string]       source elements to package
        --pkg-user [string]          Owner of package's elements
        --pkg-group [string]         Group of package's elements
        --template-activated [yes|no]
                                     Activate fpm templating mode
        --template-value [string key:value]
                                     Couple key:value for fpm templating
        --pkg-preinst [string]       Path to pre-install package script
        --pkg-postinst [string]      Path to post-install package script
        --pkg-prerm [string]         Path to pre-delete package script
        --pkg-postrm [string]        Path to post-delete package script
        --pkg-iteration [string]     Package iteration
        --pkg-epoch [integer]        Package epoch value
        --easyfpm-pkg-changelog [string]
                                     Path to an easyfpm format changelog file
        --pkg-vendor [string]        Package vendor name
        --pkg-url [string]           Package vendor url
        --pkg-license [string]       Package license
        --pkg-config-files [string]  Files or directories considered as conf in the targeted OS
                                      (can be declared multiple time)
        --pkg-depends [string]       Package dependancie
                                      (can be declared multiple times)
        --pkg-suffix [string]        Package suffix
        --pkg-changelog [string]     Package changelog (in the wanted format for the package)
        --pkg-force [yes|no]         Force package generation even if the same name exists
        --pkg-category [string]      Category for this package
        --pkg-provides [string]      A tag of what provides this package
                                      (can be declared multiple times)
        --pkg-conflicts [string]     Other packages that conflict with that one
                                      (can be declared multiple times)
        --pkg-recommends [string]    Other package to recommend
                                      (can be declared multiple times)
        --pkg-suggests [string]      Other package to suggests
                                      (can be declared multiple times)
        --pkg-directories [string]   Mark recursively a directory on the targeted system as being owned by the package
                                      (can be declared multiple times)
        --pkg-maintainer [string]    The maintainer of this package
        --pkg-compression [string]   The compression to use with this package (may not be possible)
        --pkg-priority [string]      The package 'priority' (depends of the targetted package type
        --pkg-replaces [string]      Other packages this package replace
                                      (can be declared multiple times)
    -v, --verbose                    Verbose mode
        --debug                      Debug mode
    -n, --dry-run                    Do not exec fpm, juste print what would be done
        --version                    Display version and quit
        --label-list                 Display the availables labels and quit
        --help                       Display help and quit
```

## Example of config file ##

this config file can be found in easyfpm/doc/samples/easyfpm.cfg

``` ini
#############################
# easyfpm sample conf
#############################
    
#
# All of these parameters can be overloaded on command-line with --key value
# Example : --pkg-name easyfpm
#
# All the params with an uniline value (see fpm doc) can be templated on this script with {{key}}
# Example : pkg-mapping={{pkg-src-dir}}/_easyfpm/mapping.conf
#

#
# For each couple value key, the priority for value is :
# 1) the --key value given in command line
# 2) the key=value present in a [section]
# 3) the key=value in global section (before any [section] declaration)
#

#
# Package name
pkg-name=easyfpm

#
# Description
#
pkg-description="Tool wrapper for fpm"
pkg-description="aimly used to packages scripts"

#
# Package metadata
#
pkg-vendor=Erwan SEITE
pkg-url=https://github.com/wanix/easyfpm
pkg-licence=GPLv2


#
# Root dir for target system
# Default : /
#
pkg-prefix=/usr/local

#
# Source directory
#  If --pkg-src-dir is given on command line, this value has no effect
#pkg-src-dir=

#
# aimed arch
# 
pkg-arch=all

#
# If pkg-mapping is given, pkg-content has no effect, see the mapping example
#
#pkg-mapping={{pkg-src-dir}}/_easyfpm/mapping.conf

#
# user or group for the packaged file
#  They MUST exists on the host which make the package
#  default by fpm : root
#pkg-user=myname
#pkg-group=mygroup

#
# If template-activated is "yes", fpm will manage its templating (it is not the easyfpm one !)
template-activated=no

#
# See fpm doc for templating use in your packages' scripts
#template-value=oracle_group=dba

#
# Packages scripts if needed, see samples
#
#pkg-preinst={{pkg-src-dir}}/_easyfpm/pre-install.sh
#pkg-postinst={{pkg-src-dir}}/_easyfpm/post-install.sh
#pkg-prerm={{pkg-src-dir}}/_easyfpm/pre-delete.sh
#pkg-postrm={{pkg-src-dir}}/_easyfpm/post-delete.sh


#
# Package version
#  Given by command line for my use
#pkg-version=

#
# See fpm doc for this two values
#
pkg-iteration=1
#pkg-epoch=0


#
# If easyfpm-pkg-changelog is given AND pkg-changelog is not for a package generation,
# then easyfpm will generate a changelog in the format waited by the package (easyfpm-tranlatecl)
# The easyfpm changelog have a simple specific format (aim : administrators who make scripts)
easyfpm-pkg-changelog={{pkg-src-dir}}/changelog


#
# Which files can be seen as conf file on the target system
#
pkg-config-files={{pkg-prefix}}/MONMODULECLIENT/cfg


#############################
# Specific sections
#############################
#
# With the command line, you can make only the wanted sections with --label
# Example: --label debian6 --label debian7
# By default, easyfpm make all sections given


[debian6]
#Specific section for debian (the name I choose, not asked by easyfpm)

#
# Package type
#
pkg-type=deb

#
# Dependancies
pkg-depends=ruby1.9.1
pkg-depends=libruby-unixconfigstyle >= 1.0.0
pkg-depends=libruby-ptools >= 1.2.4
pkg-depends=libruby-fpm >= 1.1.0

#
# Suffix in the package name (concat with iteration for fpm)
#
pkg-suffix=-squeeze

[debian7]
#For Debian7 (not the same ruby name in depends)
pkg-type=deb
pkg-depends=ruby >= 1.9.1
pkg-depends=libruby-unixconfigstyle >= 1.0.0
pkg-depends=libruby-ptools >= 1.2.4
pkg-depends=libruby-fpm >= 1.1.0
pkg-suffix=-wheezy

```

## Example of mapping file ##

this config file can be found in esasyfpm/doc/samples/easyfpm.cfg

``` shell
#
# This is a mapping sample
#
# source file (root dir is pkg-src-dir) => destination (root dir is pkg-prefix)
#

#This example suppose we want to package an apache specific configuration
# Tree on dev
# myapp
#   conf.d/myapp.conf
#   site/<php code>
#   doc
# 
# the pkg-source-dir is /home/packager/retrieve/myapp
# the pkg-prefix is /

conf.d/myapp.conf => etc/apache2/site-available/myapp.conf
site => app/httpd/www/myapp
doc => usr/share/doc/myapp

```

## Example of use ##

This tool can be used to make multiple packages in one shot.
I made for my company a wrapper which get a module in our CSV, look for an _easyfpm dir an then execute easyfpm with _easyfpm/easyfpm.cfg as config file.

consider the following module:

``` text
ExampleModule
  |
  ---> _easyfpm
        |
        ---> easyfpm.cfg
        ---> mapping_exampleModule.conf
        ---> pre-install.sh
        ---> post-delete.sh
        ---> post-install.sh
  ---> bin
        |
        ---> EM_doMyJob.sh
        ---> EM_verifyIt.sh
  ---> cfg
        |
        ---> EM_doMyJob.conf
  ---> cron.d
        |
        ---> EM_doMyJob
```

To deploy this module, I want to verify the existence of user exmoduser and create it if it not exists.This is done by pre-install.sh
To uninstall this module, I delete all the files from it and remove the user exmoduser. This last action is done by post-delete.sh.

I want to deploy bin/*.sh in /exploit/bin/
I want to deploy cfg/*.conf in /exploit/cfg/
I want to deploy cron.d/* in /etc/cron.d/
This mapping is done by mapping_exampleModule.conf

I want the file deployed in bin to be executable and owned by exmoduser and the config files in /exploit/cfg/ should be readable by exmoduser, this is done by post-install.sh

The wrapper is easy to use for admins, they launche on the build machine the following command:

makePackage --module ExampleModule --version 1.0 

this command get the tag 1.0 of module ExampleModule on our git server an after launch easyfpm with a command like this :
easyfpm --config-file /packaging/cfg/makepackages/default-easyfpm.conf --config-file /packaging/tempodata/ExampleModule/_easyfpm/easyfpm.cfg --pkg-src-dir /packaging/tempodata/ExampleModule --pkg-version 1.0 --pkg-output-dir /packaging/output

After few seconds, we have 5 new packages generated in /packaging/output:
* ExampleModule_1.0-1_all-squeeze.deb
* ExampleModule_1.0-1_all-wheezy.deb
* ExampleModule-1.0-1.el5.noarch.rpm
* ExampleModule-1.0-1.el6.noarch.rpm
* ExampleModule-1.0-1.el7.noarch.rpm

## easyfpm changelog format ##

the changelog accept comment lines which start with '#'
this lines are ignored for changelog generation in specific deb or rpm format.

The changelog header lines are identified by the following regexp:

``` perl
/^\s*((\d{4}-?\d{2}-?\d{2}) (\d{2}:\d{2}:\d{2} )?)?Version (\d+\.\d+(\.\d+)?(-\d+)?) (.+? )?\(((.+?)(@| at ).+?\.[\d\w]+)\)\s*$/i
```

the lines following header must be 'two spaces' separated.

### Changelog Example 1 ###
``` shell
################################################################################
# -- MySuperProg --
# SRC    : http://github.com/awsome/mysuperprog.git
# ISSUES : http://github.com/awsome/mysuperprog/issues
################################################################################
20151124 11:20:00 Version 1.1 John DOE (john.doe@mybox.com)
  I had a new function
  Merge from 1.0.1, thanks Jane Doe

20151123 12:05:00 Version 1.0 John DOE (john.doe@mybox.com)
  my first release
  I put in it:
    sommething
    something else
```
#### Transforming Example 1 in deb format ####
``` shell
user@host:~$ easyfpm-translatecl -f /tmp/changelog -p mysuperprog -t deb
mysuperprog (1.1) stable; urgency=low
  * I had a new function
  * Merge from 1.0.1, thanks Jane Doe
 -- John DOE  <john.doe@mybox.com>  Tue 24 Nov 2015 11:20:00 +0100

mysuperprog (1.0) stable; urgency=low
  * my first release
  * I put in it:
    sommething
    something else
 -- John DOE  <john.doe@mybox.com>  Mon 23 Nov 2015 12:05:00 +0100
```
#### Transforming Example 1 in rpm format ####
``` shell
user@host:~$ easyfpm-translatecl -f /tmp/changelog -p mysuperprog -t rpm
* Tue Nov 24 2015 John DOE  <john.doe@mybox.com> 1.1
  - I had a new function
  - Merge from 1.0.1, thanks Jane Doe

* Mon Nov 23 2015 John DOE  <john.doe@mybox.com> 1.0
  - my first release
  - I put in it:
    - sommething
    - something else
```

### Changelog Example 2 ###
``` shell
20151124 Version 1.1 John DOE (john.doe at mybox.com)
  I had a new function
  Merge from 1.0.1, thanks Jane Doe

20151123 Version 1.0 John DOE (john.doe at mybox.com)
  my first release
  I put in it:
    sommething
    something else
```

#### Transforming Example 2 in deb format ####

``` shell
user@host:~$ easyfpm-translatecl -f /tmp/changelog -p mysuperprog -t deb
mysuperprog (1.1) stable; urgency=low
  * I had a new function
  * Merge from 1.0.1, thanks Jane Doe
 -- John DOE  <john.doe at mybox.com>  Tue 24 Nov 2015 00:00:00 +0100

mysuperprog (1.0) stable; urgency=low
  * my first release
  * I put in it:
    sommething
    something else
 -- John DOE  <john.doe at mybox.com>  Mon 23 Nov 2015 00:00:00 +0100
```

#### Transforming Example 2 in rpm format ####

``` shell
user@host:~$ easyfpm-translatecl -f /tmp/changelog -p mysuperprog -t rpm
* Tue Nov 24 2015 John DOE  <john.doe at mybox.com> 1.1
  - I had a new function
  - Merge from 1.0.1, thanks Jane Doe

* Mon Nov 23 2015 John DOE  <john.doe at mybox.com> 1.0
  - my first release
  - I put in it:
    - sommething
    - something else
```

## Projects using easyfpm ##
* https://github.com/wanix/mkpackage-tomcat7
