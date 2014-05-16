###############################################################################
## Class   : EASYFPM::CommandLine
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Command Line
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "optparse"
begin
  require "unixconfigstyle"
rescue LoadError
  require "rubygems"
  require "unixconfigstyle"
end


class EASYFPM::CommandLine

  def initialize()
    @easyfpmconf = UnixConfigStyle.new()
    @verbose = false
    @dryrun = false
    @debug=false
    @labels = []
    parse()
  end


  #(private) Parse the command line arguments and create a UnixConfigStyle object
  def parse(*args)
    easyfpmconffiles = []
    options = {}
    labelListAsked = false
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage easyfpm [options]"

      opts.on("--config-file [string]", String, "Configuration file's path", " (can be declared multiple times, declarative order is priority order)") do |opt|
        easyfpmconffiles.push(opt)
      end

      opts.on("--label [list by comma]", String, "Labels to work with", " (can be declared multiple times)") do |opt|
        @labels.concat(opt.split(','))
      end

      opts.on("--pkg-name [string]", String, "Package name") do |opt|
        @easyfpmconf.addValues(opt,"pkg-name")
      end

      opts.on("--pkg-type [string]", String, "Package type") do |opt|
        @easyfpmconf.addValues(opt,"pkg-type")
      end

      opts.on("--pkg-version [string]", String, "Package version, example 1.0") do |opt|
        @easyfpmconf.addValues(opt,"pkg-version")
      end
 
      opts.on("--pkg-src-dir [string]", String, "Package source dir") do |opt|
        @easyfpmconf.addValues(opt,"pkg-src-dir")
      end

      opts.on("--pkg-mapping [string]", String, "Package install map file") do |opt|
        @easyfpmconf.addValues(opt,"pkg-mapping")
      end

      opts.on("--pkg-prefix [string]", String, "Package installation prefix") do |opt|
        @easyfpmconf.addValues(opt,"pkg-prefix")
      end

      opts.on("--pkg-output-dir [string]", String, "Destination dir for packages") do |opt|
        @easyfpmconf.addValues(opt,"pkg-output-dir")
      end

      opts.on("--pkg-description [string]", String, "Package description") do |opt|
        @easyfpmconf.addValues(opt,"pkg-description")
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

      opts.on("--pkg-license [string]", String, "Package license") do |opt|
        @easyfpmconf.addValues(opt,"pkg-license")
      end

      opts.on("--pkg-config-files [string]", String, "Files or directories considered as conf in the targeted OS", " (can be declared multiple time)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-config-files")
      end

      opts.on("--pkg-depends [string]", String, "Package dependancie"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-depends")
      end

      opts.on("--pkg-suffix [string]", String, "Package suffix") do |opt|
        @easyfpmconf.addValues(opt,"pkg-suffix")
      end

      opts.on("--pkg-changelog [string]", String, "Package changelog (in the wanted format for the package)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-changelog")
      end

      opts.on("--pkg-force [yes|no]", String, "Force package generation even if the same name exists") do |opt|
        @easyfpmconf.addValues(opt,"pkg-force")
      end

      opts.on("--pkg-category [string]", String, "Category for this package") do |opt|
        @easyfpmconf.addValues(opt,"pkg-category")
      end

      opts.on("--pkg-provides [string]", String, "A tag of what provides this package"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-provides")
      end

      opts.on("--pkg-conflicts [string]", String, "Other packages that conflict with that one"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-conflicts")
      end

      opts.on("--pkg-recommends [string]", String, "Other package to recommend"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-recommends")
      end

      opts.on("--pkg-suggests [string]", String, "Other package to suggests"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-suggests")
      end

      opts.on("--pkg-directories [string]", String, "Mark recursively a directory on the targeted system as being owned by the package"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-directories")
      end

      opts.on("--pkg-maintainer [string]", String, "The maintainer of this package") do |opt|
        @easyfpmconf.addValues(opt,"pkg-maintainer")
      end

      opts.on("--pkg-compression [string]", String, "The compression to use with this package (may not be possible)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-compression")
      end

      opts.on("--pkg-priority [string]", String, "The package 'priority' (depends of the targetted package type") do |opt|
        @easyfpmconf.addValues(opt,"pkg-priority")
      end

      opts.on("--pkg-replaces [string]", String, "Other packages this package replace"," (can be declared multiple times)") do |opt|
        @easyfpmconf.addValues(opt,"pkg-replaces")
      end

      opts.on("-v", "--verbose", "Verbose mode") do |opt|
        @verbose = true;
      end

      opts.on("--debug", "Debug mode") do |opt|
        @debug = true;
      end

      opts.on("-n", "--dry-run", "Do not exec fpm, juste print what would be done") do |opt|
        @dryrun = true;
      end

      opts.on("--version", "Display version and quit") do |opt|
        puts "easyfpm version #{EASYFPM::VERSION}"
        exit
      end

      opts.on("--label-list", String, "Display the availables labels and quit") do |opt|
        labelListAsked=true
      end

      opts.on("--help", "Display help and quit") do |opt|
        puts opts
        exit
      end
    end #OptionParser.new do
    
    optparse.parse!
    easyfpmconffiles.each do |conffile|
      @easyfpmconf.push_unix_config_file(conffile)
    end
    if labelListAsked
      labels = @easyfpmconf.getSections()
      if labels.empty?
        puts "No labels available"
      else
        puts "Availables labels :"
        labels.each do |label|
          puts " - "+label
        end
      end
      exit
    end
  end #parse
  private :parse

  # For debugging purpose, print the UnixConfigStyle object for this instance
  def print()
    @easyfpmconf.print()
  end #print

  # Run the command line given
  #def run(*args)
  def run()
    returnCode=true
    if @labels.empty?
      easyfpmpkg = EASYFPM::Packaging.new(@easyfpmconf)
      easyfpmpkg.verbose = @verbose
      easyfpmpkg.dryrun = @dryrun
      easyfpmpkg.debug = @debug
      returnCode=false unless easyfpmpkg.makeAll()
    else
      @labels.each do |label|
        easyfpmpkg = EASYFPM::Packaging.new(@easyfpmconf,label)
        easyfpmpkg.verbose = @verbose
        easyfpmpkg.dryrun = @dryrun
        easyfpmpkg.debug = @debug
        returnCode=false unless easyfpmpkg.make(label)
      end
    end
    return returnCode
  end #run
end
