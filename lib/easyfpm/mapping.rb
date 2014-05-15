###############################################################################
## Class   : EASYFPM::Mapping
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM Mapping Conf Files
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm/exceptions"

class EASYFPM::Mapping

  @@regexpStruct={}
  #Empty line definition
  @@regexpStruct[:emptyline] = /^\s*$/
  #Comment line definition
  @@regexpStruct[:commentline] = /^\s*[#]/
  #Mapping line definition
  @@regexpStruct[:mappingline] = /^\s*(.+?)\s+=>\s+(.*?)\s*$/

  attr_reader :hashmap

  def initialize(mappingfile)
    file = File.open(mappingfile, 'r')
    @hashmap={}
    while !file.eof?
      line = file.readline
      #We ignore the empty lines
      next if @@regexpStruct[:emptyline].match(line)
      #We ignore the comment lines
      next if @@regexpStruct[:commentline].match(line)
      linematch = @@regexpStruct[:mappingline].match(line)
      if linematch
        #We are on a mapping line
        @hashmap[linematch[1]]=linematch[2]
      else
        raise EASYFPM::InvalidConfiguration, "The following line is not recognized in mapping file #{mappingfile}:\n\t#{line}"
      end
    end
  end #initialize
end
