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
require "ptools"

class EASYFPM::Packaging

  attr_accessor :verbose
  attr_accessor :dryrun

  #Initialize the class
  def initialize(unixconfigstyle, specificLabel=nil)
    raise ArgumentError, 'the argument must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle

    #We need fpm in the path
    raise EASYFPM::InvalidEnvironment, "the fpm script is not found in PATH, please install it or put it in your PATH" unless File.which("fpm")

    @easyfpmconf = EASYFPM::Configuration.new(unixconfigstyle, specificLabel)
    @label=specificLabel
    self.verbose = false
    self.dryrun = false
  end #initialize

  #return a fpmcmdline for the specific label
  def generatefpmline(labelhashconf)
    return nil unless labelhashconf
    fpmconf=""
    return fpmconf
  end #generatefpmline

  #Create the packages
  def make()
    @easyfpmconf.print()
    return true
  end #make
end
