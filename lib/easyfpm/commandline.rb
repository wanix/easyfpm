###############################################################################
## Class   : EASYFPM::CommandLine
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Command Line
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "optparse"
class EASYFPM::CommandLine

  def initialize()
    @easyfpmconf = UnixConfigStyle.new()
    @verbose = false
    @dryrun = false
  end


  #(private) Parse the command line arguments and create a UnixConfigStyle object
  def parse(*args)
    easyfpmconffiles = []
    options = {}
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage easyfpm [options]"

      opts.on("--config-file [string]", String, "Configuration file's path", " (can be declared multiple time, declarative order is priority order)") do |opt|
        easyfpmconffiles.push(opt)
      end

      opts.on("--pkg-src-dir [string]", String, "Package source dir") do |opt|
        @easyfpmconf.addValues(opt,"pkg-src-dir")
      end

      opts.on("--pkg-mapping [string]", String, "Package install map file") do |opt|
        @easyfpmconf.addValues(opt,"pkg-mapping")
      end

      opts.on("--pkg-version [string]", String, "Package version, example 1.0") do |opt|
        @easyfpmconf.addValues(opt,"pkg-version")
      end

      opts.on("--pkg-output-dir [string]", String, "Destination dir for packages") do |opt|
        @easyfpmconf.addValues(opt,"pkg-output-dir")
      end

      opts.on("--pkg-name [string]", String, "Package name") do |opt|
        @easyfpmconf.addValues(opt,"pkg-name")
      end

      opts.on("--pkg-description [string]", String, "Package description") do |opt|
        @easyfpmconf.addValues(opt,"pkg-description")
      end

      opts.on("--pkg-prefix [string]", String, "Package installation prefix") do |opt|
        @easyfpmconf.addValues(opt,"pkg-prefix")
      end

      opts.on("--pkg-arch [string]", String, "Package architecture") do |opt|
        @easyfpmconf.addValues(opt,"pkg-arch")
      end

      opts.on("--pkg-content [string]", String, "source elements to package") do |opt|
        @easyfpmconf.addValues(opt,"pkg-content")
      end

      opts.on("--pkg-user [string]", String, "Owner of package's elements") do |opt|
        @easyfpmconf.addValues(opt,"pkg-user")
      end

      opts.on("--pkg-group [string]", String, "Group of package's elements") do |opt|
        @easyfpmconf.addValues(opt,"pkg-group")
      end

      opts.on("--template-activated [yes|no]", String, "Activate fpm templating mode") do |opt|
        @easyfpmconf.addValues(opt,"template-activated")
      end

      opts.on("--template-value [string key:value]", String, "Couple key:value for fpm templating") do |opt|
        @easyfpmconf.addValues(opt,"template-value")
      end

      opts.on("--pkg-preinst [string]", String, "Path to pre-install package script") do |opt|
        @easyfpmconf.addValues(opt,"pkg-preinst")
      end

      opts.on("--pkg-postinst [string]", String, "Path to post-install package script") do |opt|
        @easyfpmconf.addValues(opt,"pkg-postinst")
      end

      opts.on("--pkg-prerm [string]", String, "Path to pre-delete package script") do |opt|
        @easyfpmconf.addValues(opt,"pkg-prerm")
      end

      opts.on("--pkg-postrm [string]", String, "Path to post-delete package script") do |opt|
        @easyfpmconf.addValues(opt,"pkg-postrm")
      end

      opts.on("--pkg-iteration [string]", String, "Package iteration") do |opt|
        @easyfpmconf.addValues(opt,"pkg-iteration")
      end

      opts.on("--pkg-epoch [integer]", Integer, "Package epoch value") do |opt|
        @easyfpmconf.addValues(opt,"pkg-epoch")
      end

      opts.on("--easyfpm-pkg-changelog [string]", String, "Path to an easyfpm format changelog file") do |opt|
        @easyfpmconf.addValues(opt,"easyfpm-pkg-changelog")
      end

      opts.on("--pkg-vendor [string]", String, "Package vendor name") do |opt|
        @easyfpmconf.addValues(opt,"pkg-vendor")
      end

      opts.on("--pkg-url [string]", String, "Package vendor url") do |opt|
        @easyfpmconf.addValues(opt,"pkg-url")
      end

      opts.on("--pkg-licence [string]", String, "Package licence") do |opt|
        @easyfpmconf.addValues(opt,"pkg-licence")
      end

      opts.on("--pkg-config-files [string]", String, "Files or directories considered as conf in the targeted OS", " (can be declared multiple time)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-config-files")
      end

      opts.on("--pkg-type [string]", String, "Package type") do |opt|
        @easyfpmconf.addValues(opt,"pkg-type")
      end

      opts.on("--pkg-depends [string]", String, "Package dependancie"," (can be declared multiple time)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-depends")
      end

      opts.on("--pkg-suffix [string]", String, "Package suffix") do |opt|
        @easyfpmconf.addValues(opt,"pkg-suffix")
      end

      opts.on("--pkg-changelog [string]", String, "Package suffix") do |opt|
        @easyfpmconf.addValues(opt,"pkg-suffix")
      end

      opts.on("-v", "--verbose", "Verbose mode") do |opt|
        @verbose = true;
      end

      opts.on("-n", "--dry-run", "Do not exec fpm, juste print what would be done") do |opt|
        @dryrun = true;
      end

      opts.on("--version", "Display version") do |opt|
        puts "easyfpm version #{EASYFPM::VERSION}"
        exit
      end

      opts.on("--help", "Display help") do |opt|
        puts opts
        exit
      end
    end #OptionParser.new do
    
    optparse.parse!
    easyfpmconffiles.each do |conffile|
      @easyfpmconf.push_unix_config_file(conffile)
    end
  end #parse
  private :parse

  # For debugging purpose, print the UnixConfigStyle object for this instance
  def print()
    @easyfpmconf.print()
  end #print

  # Run the instructions given by command line
  # Parse the command line arguments and then create packages
  def run(*args)
    parse()
    easyfpmpkg = EASYFPM::Packaging.new(@easyfpmconf)
    easyfpmpkg.verbose = @verbose
    easyfpmpkg.dryrun = @dryrun
    easyfpmpkg.make()
  end #run

end
