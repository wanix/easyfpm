###############################################################################
## Class   : EASYFPM::CommandLine
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Command Line
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "unixconfigstyle"

class EASYFPM::Packaging

  attr_accessor :verbose
  attr_accessor :dryrun

  #Initialize the class
  def initialize(unixconfigstyle)
    raise ArgumentError, 'the argument must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle
    @easyfpmconf = unixconfigstyle
    self.verbose = false
    self.dryrun = false
  end

  #Create the packages
  def make()
    return true
  end

end
