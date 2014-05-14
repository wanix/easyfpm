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

  #Initialize the class
  def initialize (unixconfigstyle, specificLabel=nil)
    raise ArgumentError, 'the argument "unixconfigstyle" must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle
    raise ArgumentError, 'the argument "specificLabel" must be an String' unless (specificLabel.is_a? String or specificLabel == nil)
    
    @conf={}
    createconf(unixconfigstyle,specificLabel)
    #replaceTemplateVars()
    #validate()
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
  def replaceTemplateVars()
    #We start to scan each value if a var is present
    return false if @params.isEmpty?
    if @params.haveKeys?
      @params.getKeys.each do |myKey|
        @params.getValues(myKey).each_index do |myValueIndex|
          if containTemplateVar? @params.getValue(myKey, myValueIndex)
            replaceTemplateVar(@params.getValue(myKey, myValueIndex))
            #@params.replaceValue(replaceTemplateVar(@easyfpmconf.getValue(myKey, myValueIndex)),myKey,myValueIndex)
          end
        end #@params.getValues(myKey).each_index
      end #@params.getKeys.each do
    end #if @params.haveKeys?
  end #replaceTemplateVars
  private :replaceTemplateVars

  # (private) Validate the given configuration and clean it if necessary
  def validate
    #We have to analyse each parameters for the global conf and for each section conf
    return true
  end
  private :validate

  # (private) return true if the string contain at list one var
  def containTemplateVar?(myString)
    return true if myString.match(@@templateVarExpReg)
    return false
  end
  private :containTemplateVar?

  # (private) return a string with vars replaced if a corresponding value is found
  def replaceTemplateVar(myString)
    #foreach matchdata on each string
    myString.to_enum(:scan, @@templateVarExpReg).map { Regexp.last_match }.each do |matchData|
      puts matchData[2]
    end #myString.to_enum(:scan...
  end
  private :replaceTemplateVar

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
    if (label == @@defaultLabelName)
    else
    end
  end
  private :printLabelConf

end
