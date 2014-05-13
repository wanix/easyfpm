###############################################################################
## Class   : EASYFPM::Packaging
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Command Line
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "unixconfigstyle"
require "tempfile"

class EASYFPM::Packaging

  attr_accessor :verbose
  attr_accessor :dryrun

  #Initialize the class
  def initialize(unixconfigstyle)
    raise ArgumentError, 'the argument must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle
    @easyfpmconf = EASYFPM::Configuration.new(unixconfigstyle)
    self.verbose = false
    self.dryrun = false
  end

  #Create the packages
  def make(easyfpmSectionName=nil)
    @easyfpmconf.print(easyfpmSectionName)
    return true
  end

end
