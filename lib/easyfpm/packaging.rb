###############################################################################
## Class   : EASYFPM::Packaging
## Author  : Erwan SEITE
## Aim     : Create packages with fpm
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm/configuration"
require "easyfpm/exceptions"
require "easyfpm/pkgchangelog"
require "fileutils"
require "tempfile"
require "tmpdir"
require "open3"
begin
  require "unixconfigstyle"
  require "ptools"
rescue LoadError
  require "rubygems"
  require "unixconfigstyle"
  require "ptools"
end


class EASYFPM::Packaging

  attr_accessor :verbose
  attr_accessor :dryrun
  attr_accessor :debug

  #Initialize the class
  def initialize(unixconfigstyle, specificLabel=nil)
    raise ArgumentError, 'the argument must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle

    #We need fpm in the path
    raise EASYFPM::InvalidEnvironment, "the fpm script is not found in PATH, please install it or put it in your PATH" unless File.which("fpm")

    @easyfpmconf = EASYFPM::Configuration.new(unixconfigstyle, specificLabel)
    @label=specificLabel
    @verbose = false
    @dryrun = false
    @debug = false
  end #initialize

  #return a fpmcmdline for the specific label
  def generatefpmline(labelhashconf,makingConf=nil)
    debug "generatefpmline","generatefpmline (#{labelhashconf.class.name},#{makingConf.class.name})"
    return nil unless labelhashconf
    fpmconf=""

    fpmconf += " --verbose" if @verbose
    fpmconf += " --debug" if @debug

    packageType = labelhashconf["pkg-type"]

    #Let analyse the options given
    labelhashconf.each_key do |param|
      case param
        #The followings params have specific treatments
        when "pkg-mapping", "pkg-content"
          next
        when "easyfpm-pkg-changelog"
          #We should have generate a temporary file for this
          raise EASYFPM::MissingArgument, "The easyfpm changelog has not been generated" unless makingConf.has_key? "pkg-changelog"
          case packageType
            when "deb","rpm"
              fpmconf += " --#{packageType}-changelog '"+makingConf["pkg-changelog"]+"'"
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType          
        when "pkg-name"
          fpmconf += " --name "+labelhashconf[param]
        when "pkg-type"
          fpmconf += " -t "+labelhashconf[param]
        when "pkg-version"
          fpmconf += " -v "+labelhashconf[param]
        when "pkg-src-dir"
          #If we have a mapping file, we have to rebuild the source later in temporary dir
          fpmconf += " -s dir -C "+labelhashconf[param] unless labelhashconf.has_key? "pkg-mapping"
        when "pkg-prefix"
          fpmconf += " --prefix "+labelhashconf[param]
        #There's a bug with pkg-output-dir and deb so easyfpm make it itself
        when "pkg-output-dir"
          next
        #  fpmconf += " -p "+labelhashconf[param]
        when "pkg-description"
          fpmconf += " --description '"+labelhashconf[param]+"'"
        when "pkg-arch"
          fpmconf += " -a "+labelhashconf[param]
        when "pkg-user"
          case packageType
            when "deb","rpm","solaris"
              fpmconf += " --#{packageType}-user "+labelhashconf[param]
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType
        when "pkg-group"
          case packageType
            when "deb","rpm","solaris"
              fpmconf += " --#{packageType}-group "+labelhashconf[param]
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType
        when "template-activated"
          fpmconf += " --template-scripts" if labelhashconf[param] == "yes"
        when "template-value"
          #We have an Array for this param
          labelhashconf[param].each do |tplvalue|
            fpmconf += " --template-value "+tplvalue
          end #labelhashconf[param].each
        when "pkg-preinst"
          fpmconf += " --before-install "+labelhashconf[param]
        when "pkg-postinst"
          fpmconf += " --after-install "+labelhashconf[param]
        when "pkg-prerm"
          fpmconf += " --before-remove "+labelhashconf[param]
        when "pkg-postrm"
          fpmconf += " --after-remove "+labelhashconf[param]
        when "pkg-iteration"
          fpmconf += " --iteration "+labelhashconf[param]
        when "pkg-epoch"
          fpmconf += " --epoch "+labelhashconf[param]
        when "pkg-vendor"
          fpmconf += " --vendor '"+labelhashconf[param]+"'"
        when "pkg-url"
          fpmconf += " --url '"+labelhashconf[param]+"'"
        when "pkg-license"
          fpmconf += " --license '"+labelhashconf[param]+"'"
        when "pkg-config-files"
          #We have an Array for this param
          labelhashconf[param].each do |pkgconfig|
            fpmconf += " --config-files '"+pkgconfig+"'"
          end #labelhashconf[param].each
        when "pkg-depends"
          #We have an Array for this param
          labelhashconf[param].each do |pkgdepend|
            fpmconf += " -d '"+pkgdepend+"'"
          end #labelhashconf[param].each
        when "pkg-suffix"
          #Due to a lack in fpm, the pkg-suffix is use only in package renaming
          next 
        when "pkg-changelog"
          case packageType
            when "deb","rpm"
              fpmconf += " --#{packageType}-changelog "+labelhashconf[param]
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType 
        when "pkg-force"
          fpmconf += " -f" if labelhashconf[param] == "yes"
        when "pkg-category" 
          fpmconf += " --category "+labelhashconf[param]
        when "pkg-provides" 
          #We have an Array for this param
          labelhashconf[param].each do |pkgprovide|
            fpmconf += " --provides '"+pkgprovide+"'"
          end #labelhashconf[param].each
        when "pkg-conflicts"
          #We have an Array for this param
          labelhashconf[param].each do |pkgconflict|
            fpmconf += " --conflicts '"+pkgconflict+"'"
          end #labelhashconf[param].each
        when "pkg-recommends"
          #We have an Array for this param
          case packageType
            when "deb"
              labelhashconf[param].each do |pkgrecommends|
                fpmconf += " --#{packageType}-recommends '"+pkgrecommends+"'"
              end #labelhashconf[param].each
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType 
        when "pkg-suggests"
          #We have an Array for this param
          case packageType
            when "deb"
              labelhashconf[param].each do |pkgsuggests|
                fpmconf += " --#{packageType}-suggests '"+pkgsuggests+"'"
              end #labelhashconf[param].each
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType
        when "pkg-directories"
          fpmconf += " --directories "+labelhashconf[param]
        when "pkg-maintainer"
          fpmconf += " --maintainer "+labelhashconf[param]
        when "pkg-compression"
          case packageType
            when "deb","rpm"
              fpmconf += " --#{packageType}-compression "+labelhashconf[param]
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType 
        when "pkg-priority"
          case packageType
            when "deb"
              fpmconf += " --#{packageType}-priority "+labelhashconf[param]
          else
            warn "Warning: the package type #{packageType} doesn't use "+param
          end #case packageType
        when "pkg-replaces"
          #We have an Array for this param
          labelhashconf[param].each do |pkgreplace|
            fpmconf += " --replaces '"+pkgreplace+"'"
          end #labelhashconf[param].each
      else
        warn "Warning: parameter #{param} not taken into account in EASYFPM::Packaging.generatefpmline (should be a bug)"
      end #case param
    end #labelhashconf.each_key

    #if we have pkg-content, we must insert it at the end of the string
    fpmconf += " "+labelhashconf["pkg-content"] if labelhashconf.has_key? "pkg-content"

    #If we have pkg-mapping, the temporary dir should have been created and
    # the content to manage in makingConf["pkg-content"]
    if labelhashconf.has_key? "pkg-mapping"
      #The new source dir has been generated
      fpmconf += " -s dir -C '"+makingConf["pkg-src-dir"]+"'"
      #The new content is mapped
      fpmconf += " "+makingConf["pkg-content"]
    end

    return fpmconf
  end #generatefpmline

  #make alls packages in the configuration
  def makeAll()
    debug "makeAll"
    returnCode = true
    if @easyfpmconf.hasLabels?
      @easyfpmconf.getLabels().each do |label|
        returnCode = false unless make(label)
      end #@easyfpmconf.getLabels().each
    else
      returnCode = false unless make()
    end
    return returnCode
  end

  #Create the packages
  def make(label=nil)
    returnCode=true
    begin
      debug "make", "make(#{label})"
      #Make packages for each labels in conf
    
      if @debug
        puts "*"*80
        puts "  EASYFPM::Packaging : configuration"
        puts "*"*80
        @easyfpmconf.print(label) 
        puts "*"*80
      end

      labelconf = @easyfpmconf.getLabelHashConf(label)

      makingConf={}
      #Do we need to generate the changelog ?
      if labelconf.has_key? "easyfpm-pkg-changelog"
        #Create a temp file
        makingConf["file-easyfpm-pkg-changelog"]=Tempfile.new("easyfpm-pkg-changelog")
        #Give it for config
        makingConf["pkg-changelog"]=makingConf["file-easyfpm-pkg-changelog"].path
        debug "make","Generating easyfpm changelog #{makingConf["pkg-changelog"]}"
        #Create a easyfpm-changelog object from file
        easyfpmcl = EASYFPM::PkgChangelog.new(labelconf["easyfpm-pkg-changelog"])
        #Writing a changelog for package type in temp file
        easyfpmcl.write(labelconf["pkg-type"],makingConf["pkg-changelog"])
      end

      #Do we have a mapping file ?
      # If so we have to recreate the source directory
      if labelconf.has_key? "pkg-mapping"
        hashmap = EASYFPM::Mapping.new(labelconf["pkg-mapping"]).hashmap
        makingConf["pkg-content"] = hashmap.values.join(" ")
        makingConf["pkg-src-dir"] = Dir.mktmpdir("easyfpm-mapping")
        debug "make","mapping pkg-src-dir into #{makingConf["pkg-src-dir"]}"
        #We copy from pkg-src-dir to temp dir
        hashmap.keys.each do |file|
          #First, we create the arborescence if it doesn't exists
          newArbo = File.dirname(hashmap[file])
          unless newArbo == "."
            debug "make","creating "+makingConf["pkg-src-dir"]+"/"+newArbo
            FileUtils.mkdir_p(makingConf["pkg-src-dir"]+"/"+newArbo) unless Dir.exist?(makingConf["pkg-src-dir"]+"/"+newArbo)
          end
          #Then copy the source into it
          debug "make", "copying #{labelconf["pkg-src-dir"]}/#{file} to "+makingConf["pkg-src-dir"]+"/"+hashmap[file]
          if (@verbose or @debug)
            FileUtils.cp_r(labelconf["pkg-src-dir"]+"/"+file, makingConf["pkg-src-dir"]+"/"+hashmap[file], :preserve => true, :verbose => true)
          else
            FileUtils.cp_r(labelconf["pkg-src-dir"]+"/"+file, makingConf["pkg-src-dir"]+"/"+hashmap[file], :preserve => true)
          end
        end #hashmap.keys.each
      end #if labelconf.has_key? "pkg-mapping"

      #Do we have a specific output dir ?
      # there's a bug with fpm and this feature, so easyfpm take it itself for the moment
      if labelconf.has_key? "pkg-output-dir" or labelconf.has_key? "pkg-suffix"
        #Making a new tmpdir for working in
        makingConf["pkg-output-dir"] = Dir.mktmpdir("easyfpm-output-dir")
        #if pkg-output-dir is not defined, we have to put the result in the current dir
        labelconf["pkg-output-dir"] = Dir.getwd unless labelconf.has_key? "pkg-output-dir"
      end

      #We are ready to generate the fpm command
      fpmCmdOptions = generatefpmline(labelconf,makingConf)

      puts "fpm "+fpmCmdOptions if (@verbose or @debug or @dryrun)
      
      unless @dryrun
        if makingConf.has_key? "pkg-output-dir" 
          #returnCode = system "cd "+makingConf["pkg-output-dir"]+" && fpm "+fpmCmdOptions
          Open3.popen2e("cd "+makingConf["pkg-output-dir"]+" && fpm "+fpmCmdOptions) do |stdin, stdout_err, wait_thr|
            #fpm uses Cabin::channel for logging
            while line = stdout_err.gets
              #cbchannelmatch = /^\{.*:message=>"(.*?)",.+?(:level=>:(\w+),)?.*(:path=>"(.*?)")?.*\}$/.match(line)
              cbchannelmatch = /^\{.*:message=>"(.*?)",.+?(:level=>:(\w+),)?.*\}$/.match(line)
              cbpathmatch = /^\{.*:message=>"(.*?)",.*( :path=>"(.*?)").*\}$/.match(line)
              #Outline cause we have to filter messages before output if package-output-dir
              outline=nil
              if cbchannelmatch
                message = cbchannelmatch[1]
                loglevel = cbchannelmatch[3]
                path = cbpathmatch[3] if cbpathmatch
                if (loglevel == "info" and (@verbose or @debug))
                  outline = cbchannelmatch[0]
                elsif (loglevel == "debug" and @debug)
                  outline = cbchannelmatch[0]
                elsif loglevel
                  #Ni info, ni debug => warning ou error ou autre ?
                  warn message
                else
                  outline = message+" "+path if path
                  outline = message unless path
                end #if loglevel

                #Here we have the pkg-output-dir treatment
                if message == "Created package" and path
                  if labelconf.has_key? "pkg-suffix"
                    #We have to rename the package
                    case labelconf["pkg-type"]
                      when "rpm" 
                        #Suffix has to be fixed before arch and extension
                        newpathmatch = /^(.+)(\.[^.]+\.[^.]+)$/.match(path)
                        newpath=newpathmatch[1]+labelconf["pkg-suffix"]+newpathmatch[2]
                    else
                      #By default suffix is before extension
                      newpathmatch = /^(.+)(\.[^.]+)$/.match(path)
                      newpath=newpathmatch[1]+labelconf["pkg-suffix"]+newpathmatch[2]
                    end
                  else
                    newpath=path
                  end
                  if File.exists?(makingConf["pkg-output-dir"]+"/"+path)
                    puts (message+" "+makingConf["pkg-output-dir"]+"/"+path)
                    outline=nil
                    if File.exists?(labelconf["pkg-output-dir"]+"/"+newpath)
                      if labelconf.has_key?("pkg-force") and (labelconf["pkg-force"] == "yes")
                        #Move file
                        if (@verbose or @debug)
                          FileUtils.mv(makingConf["pkg-output-dir"]+"/"+path, labelconf["pkg-output-dir"]+"/"+newpath, :force => true, :verbose => true)
                        else
                          FileUtils.mv(makingConf["pkg-output-dir"]+"/"+path, labelconf["pkg-output-dir"]+"/"+newpath, :force => true)
                        end #if (@verbose or @debug)
                        puts "Package moved to #{labelconf["pkg-output-dir"]}/#{newpath}"
                        # We suppress
                      else
                        warn labelconf["pkg-output-dir"]+"/"+newpath+" already exists, use '--pkg-force yes' to force copy"
                        returnCode = false
                      end #if labelconf.has_key? "pkg-force" and labelconf["pkg-force"] == "yes"
                    else
                      #Move file
                      if (@verbose or @debug)
                        FileUtils.mv(makingConf["pkg-output-dir"]+"/"+path, labelconf["pkg-output-dir"]+"/"+newpath, :verbose => true)
                      else
                        FileUtils.mv(makingConf["pkg-output-dir"]+"/"+path, labelconf["pkg-output-dir"]+"/"+newpath)
                      end
                      puts "Package moved to #{labelconf["pkg-output-dir"]}/#{newpath}"
                    end #if File.exists?(labelconf["pkg-output-dir"]+"/"+newpath)
                  end #if File.exists?(makingConf["pkg-output-dir"]+"/"+path)
                end #message == "Created package" and path
                #We display the message if not filtered
                puts outline unless outline.nil?
              else
                puts line if line
              end #if cbchannelmatch
            end #while line=stdout_err.gets
            returnCode = false unless wait_thr.value.success?
          end #Open3.popen2e
        else
          returnCode = system  "fpm "+fpmCmdOptions
        end
      else
        puts "  dry-run mode, fpm not executed"
      end
    
    #We clean all before exiting
    ensure
      #  tempfile for changelog if created
      if makingConf.has_key? "file-easyfpm-pkg-changelog"
        makingConf["file-easyfpm-pkg-changelog"].close
        debug "make"," #{makingConf["pkg-changelog"]} deleted"
      end
      #  tempdir for mapping if created
      if makingConf.has_key? "pkg-src-dir"
        FileUtils.remove_entry_secure(makingConf["pkg-src-dir"])
        debug "make","#{makingConf["pkg-src-dir"]} deleted"
      end
      if makingConf.has_key? "pkg-output-dir"
        FileUtils.remove_entry_secure(makingConf["pkg-output-dir"])
        debug "make","#{makingConf["pkg-output-dir"]} deleted"
      end
    end #begin
    return returnCode
  end #make

  def debug (function, message="")
    puts "EASYFPM::Packaging."+function+": "+message if @debug
  end
  private :debug
end
