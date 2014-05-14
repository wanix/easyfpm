###############################################################################
## Class   : EASYFPM::Configuration
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Conf
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "unixconfigstyle"

class EASYFPM::Configuration

  @@templateVarExpReg = /(\{\{([\d\w\-_]+?)\}\})/
  @@defaultLabelName = "@@easyfpm-default@@"

  attr_reader :conf

  #Initialize the class
  def initialize (unixconfigstyle, specificLabel=nil)
    raise ArgumentError, 'the argument "unixconfigstyle" must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle
    raise ArgumentError, 'the argument "specificLabel" must be an String' unless (specificLabel.is_a? String or specificLabel == nil)
    
    @conf={}
    createconf(unixconfigstyle,specificLabel)
    raise EASYFPM::InvalidConfiguration, "No configuration found (error with the label #{specificLabel}?" if @conf.empty?
    replaceTemplateVars()
    raise EASYFPM::InvalidConfiguration, "Error(s) during validation" unless validate()
  end

  #Create the easyfpm struct configuration from an UnixConfigStyle object
  def createconf(unixconfigstyle, specificLabel=nil)
    #No work if the conf is empty
    return nil if unixconfigstyle.isEmpty?()
    #No work if the conf doesn't contain the wanted label
    return nil unless ( specificLabel==nil or unixconfigstyle.sectionExists?(specificLabel) )
    #We create an array with all keys presents in the conf
    allkeys=unixconfigstyle.getAllKeys(specificLabel)
    if (specificLabel == nil)
      if unixconfigstyle.haveSections?()
        #We have section, we create a separate conf for each one
        unixconfigstyle.getSections().each { |section| @conf[section]={} }
      else
        #No sections, only the default config
        @conf[@@defaultLabelName]={}
      end
    else
      #We create config only for this specific label
      @conf[specificLabel]={}
    end
    #We have our label(s)
    #It's now time to filter the configuration and create a valid conf

    #Foreach conf label
    @conf.each_key do |label|
      confsection=label
      confsection=unixconfigstyle.getRootSectionName() if (label==@@defaultLabelName)

      #Foreach key found
      allkeys.each do |param|
        #If the param has no value (???), next
        next unless unixconfigstyle.getValues(param,confsection,true)
        case param
          #Params for which each member of array is a string line
          when "pkg-description"
            @conf[label][param]=unixconfigstyle.getValues(param,confsection,true).join("\n").strip
         
          #Params for which each member is a string separated with a space
          when "pkg-content"
            @conf[label][param]=unixconfigstyle.getValues(param,confsection,true).join(" ").strip
           
          #Params for which we need to keep an array:
          when "pkg-depends","template-value","pkg-config-files"
            @conf[label][param]=unixconfigstyle.getValues(param,confsection,true)

        else 
            #For the others, the last one is the right string
            @conf[label][param]=unixconfigstyle.getValues(param,confsection,true).last.strip
        end #case
      end #allkeys.each
    end #@conf.each_key

  end #createconf

  # (private) replace the easyfpm vars value
  # the recursive param is here to stop multi recursive call
  # We limit the work to two calls
  def replaceTemplateVars(recursive=false)
    #We start to scan each value if a var is present
    return false if @conf.empty?
    newTemplateFound=false
    @conf.keys.each do |label|
      @conf[label].keys.each do |param|
        if (@conf[label][param].is_a? Array)
          #Array of String
          @conf[label][param].each_index do |index|
            if containTemplateVar?(@conf[label][param][index])
              @conf[label][param][index]=replaceTemplateVar(@conf[label][param][index],label)
              newTemplateFound=true if containTemplateVar?(@conf[label][param][index])
            end
          end #@conf[label][param].each_index
        else
          #Should be String
          if containTemplateVar?(@conf[label][param])
            @conf[label][param]=replaceTemplateVar(@conf[label][param],label)
            newTemplateFound=true if containTemplateVar?(@conf[label][param])
          end
        end #if (@conf[myLabel][param].is_a? Array)
      end #@conf[myLabel].keys.each
    end #@conf.getKeys.each

    #First pass done, second needed ?
    replaceTemplateVars(true) if (recursive == false and newTemplateFound == true)
    raise EASYFPM::LoopTemplateDetected, "Need more than two occurs of function replaceTemplateVars()" if (recursive == true and newTemplateFound == true)
  end
  private :replaceTemplateVars

  # (private) return true if the string contain at list one var
  def containTemplateVar?(myString)
    return false if (myString == nil)
    return true if myString.match(@@templateVarExpReg)
    return false
  end
  private :containTemplateVar?

  # (private) return a string with vars replaced if a corresponding value is found
  def replaceTemplateVar(myString, workinglabel)
#    return myString
    #foreach matchdata on each string
    myString.to_enum(:scan, @@templateVarExpReg).map { Regexp.last_match }.each do |matchData|
      myParam=matchData[2]
      #If we can't found the key, we stop
      raise EASYFPM::NoTemplateFound , "the key #{myParam} is not found for label #{workinglabel}" unless @conf[workinglabel].has_key? myParam
      #If the value is not a String, error
      raise EASYFPM::InvalidTemplateType, "the value given by the key #{myParam} can't be a multiline one" unless @conf[workinglabel][myParam].is_a? String
       #Replace the template with its value
       myString.gsub!(matchData[1],@conf[workinglabel][myParam])
    end #myString.to_enum(:scan...
    return myString
  end
  private :replaceTemplateVar

  # (private) Validate the given configuration and clean it if necessary
  def validate
    errorlist = []
    #We have to analyse some parameters and some ones MUST be present
    @conf.keys.each do |label|
      if (label == @@defaultLabelName)
        displaylabel=""
      else
        displaylabel="[section "+label+"] "
      end

      #Looking for mandatory params
      errorlist.push(displaylabel+"The parameter pkg-name (--pkg-name) MUST be given") unless @conf[label].has_key? "pkg-name"
      errorlist.push(displaylabel+"The parameter pkg-src-dir (--pkg-src-dir) MUST be given") unless @conf[label].has_key? "pkg-src-dir"
      errorlist.push(displaylabel+"The parameter pkg-version (--pkg-version) MUST be given") unless @conf[label].has_key? "pkg-version"
      errorlist.push(displaylabel+"One of the two parameters pkg-content (--pkg-content) or pkg-mapping (--pkg-mapping) MUST be given") unless (@conf[label].has_key? "pkg-content" or @conf[label].has_key? "pkg-mapping")
      errorlist.push(displaylabel+"The parameter pkg-type (--pkg-type) MUST be given") unless @conf[label].has_key? "pkg-type"

      @conf[label].keys.each do |param|
        case param
          #these parameters are directories which must exists and be readable
          when "pkg-src-dir"
            errorlist.push(displaylabel+"The directory #{@conf[label][param]} (given by --#{param}) MUST exists") unless File.directory?(@conf[label][param])

          #pkg-content can be replaced by pkg-mapping (higher priority for this last one)
          #If no mapping, all the files or directories given must existsi and be readable in pkg-src-dir
          when "pkg-content"
            next if @conf[label].has_key? "pkg-mapping"
            next unless @conf[label].has_key? "pkg-src-dir"
            #If we already have an error on pkg-src-dir, next
            next unless File.directory?(@conf[label]["pkg-src-dir"])
            @conf[label][param].split.each do |fileOrDir|
              errorlist.push(displaylabel+"The file (or directory) #{@conf[label]["pkg-src-dir"]}/#{fileOrDir} (given by --pkg-content) MUST be readable") unless (File.readable?(@conf[label]["pkg-src-dir"]+"/"+fileOrDir))
            end

          #the followings parameters must be readable files
          when "pkg-mapping","pkg-changelog","pkg-preinst","pkg-postinst","pkg-prerm","pkg-postrm"
             errorlist.push(displaylabel+"The file #{@conf[label][param]} (given by --#{param}) MUST be readable") unless (File.readable?(@conf[label][param]))

          #easyfpm-pkg-changelog has lesser priority than pkg-changelog
          when "easyfpm-pkg-changelog"
            next if @conf[label].has_key? "pkg-changelog"
            errorlist.push(displaylabel+"The file #{@conf[label][param]} (given by --#{param}) MUST be readable") unless (File.readable?(@conf[label][param]))

          #the following parameters must be writable directories
          when "pkg-output-dir"
            errorlist.push(displaylabel+"The directory #{@conf[label][param]} (given by --#{param}) MUST exists and be writable") unless (File.directory?(@conf[label][param]) and File.writable?(@conf[label][param]))

        end #case param
      end #conf[label].keys.each do
    end #@conf.keys.each
    
    unless errorlist.empty?
      warn("Errors in configuration detected:")
      errorlist.each do |currenterror|
        warn("  "+currenterror)
      end
      return false
    end
    return true
  end #validate
  private :validate

  # Print the configuration (debugging)
  def print(specificLabel=nil)
    if (specificLabel == nil)
      @conf.each_key do |label|
        printLabelConf(label)
      end 
    else
      printLabelConf(specificLabel)
    end 
  end
 
  #Print the configuration for one label (debugging)
  def printLabelConf(specificLabel)
    if (specificLabel == @@defaultLabelName)
      puts "========================================"
      puts "  Default package conf"
      puts "========================================"
    else
      puts "========================================"
      puts "  Configuration label #{specificLabel}"
      puts "========================================"
    end
    @conf[specificLabel].each_key do |param|
      header="<"+param+"> : "
      if @conf[specificLabel][param].is_a? Array
        puts header+@conf[specificLabel][param][0]
        subheader=" "*header.length()
        index=1
        while index < @conf[specificLabel][param].length()
          puts subheader+@conf[specificLabel][param][index]
          index += 1
        end 
      else
        puts header+@conf[specificLabel][param].to_s
      end #if @conf[specificLabel][param].is_a Array
    end #@conf[specificLabel].each_key
  end
  private :printLabelConf
end
