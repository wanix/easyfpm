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

  @@templateVarExpReg = /(\$\{EASYFPM_([A-Z0-9_]+?)\})/

  #Initialize the class
  def initialize(unixconfigstyle)
    raise ArgumentError, 'the argument must be an UnixConfigStyle object' unless unixconfigstyle.is_a? UnixConfigStyle
    @conf = unixconfigstyle
    replaceTemplateVars()
    validate()
  end

  # (private) replace the easyfpm vars value
  def replaceTemplateVars()
    #We start to scan each value if a var is present
    return false if @conf.isEmpty?
    if @conf.haveKeys?
      @conf.getKeys.each do |myKey|
        @conf.getValues(myKey).each_index do |myValueIndex|
          if containTemplateVar? @conf.getValue(myKey, myValueIndex)
            replaceTemplateVar(@conf.getValue(myKey, myValueIndex))
            #@conf.replaceValue(replaceTemplateVar(@easyfpmconf.getValue(myKey, myValueIndex)),myKey,myValueIndex)
          end
        end #@conf.getValues(myKey).each_index
      end #@conf.getKeys.each do
    end #if @conf.haveKeys?
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
    return myString.include? "${EASYFPM_"
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

  # Print the configuration in UnixConfigStyle format
  def print(easyfpmSectionName=nil)
    #@conf.print()
  end
 
end
