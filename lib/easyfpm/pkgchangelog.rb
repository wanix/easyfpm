###############################################################################
## Class   : EASYFPM::Changelog
## Author  : Erwan SEITE
## Aim     : Manage EASYFPM changelog Format
## Licence : GPL v2
## Source  : https://github.com/wanix/easyfpm.git
###############################################################################
require "easyfpm"
require "time"
class EASYFPM::PkgChangelog

  @@easyfpmCLRegExp={}
  @@easyfpmCLRegExp[:comment] = /^\s*#/
  @@easyfpmCLRegExp[:header] = /^\s*((\d{4}-?\d{2}-?\d{2}) (\d{2}:\d{2}:\d{2} )?)?Version (\d+\.\d+(\.\d+)?(-\d+)?) (.+? )?\(((.+?)(@| at ).+?\.[\d\w]+)\)\s*$/i
  @@easyfpmCLRegExp[:description] = /^((  )+)(.+)$/
  @@easyfpmCLRegExp[:ignored] = /^\s*$/
 
  attr_accessor :defaultDate
  attr_accessor :pkgname
  attr_accessor :distribution
  attr_accessor :urgency

  def initialize(changelogFile)
    raise ArgumentError, 'the argument "changelogFile" must be a String' unless changelogFile.is_a? String
    raise Errno::EACCES, "Can't read #{changelogFile}" unless File.readable?(changelogFile)
    @changelog=changelogFile
    self.defaultDate = Time.now
    self.pkgname = File.basename(File.dirname(changelogFile))
    self.distribution = "stable"
    self.urgency = "low"
  end

  def write (format, fileToWrite)
    raise ArgumentError, 'the argument "format" must be a String' unless format.is_a? String
    raise ArgumentError, 'the argument "fileToWrite" must be a String' unless fileToWrite.is_a? String

    File.open(fileToWrite,'w') do |file|
      case format.downcase
        when "deb", "rpm"
          return self.print(format,file)
      else
          raise EASYFPM::InvalidChangelogFormat, "The format #{format} is not (yet) implemented"
      end
    end
  end #write

  def print (format, io_obj=$stdout)
    raise ArgumentError, 'the argument "format" must be a String' unless format.is_a? String
    raise ArgumentError, 'the argument "io_obj" must be an IO class or an IO inherited class' unless io_obj.is_a? IO

    case format.downcase
      when "deb"
        return printDEB(io_obj)
      when "rpm"
        return printRPM(io_obj)
    else
        raise EASYFPM::InvalidChangelogFormat, "The format #{format} is not implemented"
    end
  end #write


  #(private) Write a RPM format changelog on an IO obj
  #Parameters:
  # io_obj : IO 
  def printRPM (io_obj=$stdout)
    returnCode = 0
    lineNumber=0
    errorLines = []
    myChangelog = File.new(@changelog, "r")
    header = {}
    while (myLine = myChangelog.gets)
      lineNumber += 1
      commentLine = @@easyfpmCLRegExp[:comment].match(myLine)
      #If we have a comment, we ignore it
      next if commentLine
      ignoredLine = @@easyfpmCLRegExp[:ignored].match(myLine)
      #Line we have explicitely to ignore
      next if ignoredLine
      headerLine = @@easyfpmCLRegExp[:header].match(myLine)
      if headerLine
        #header line is found, we analyse it
        #if a header was here before, we display a cariage return
        io_obj.puts "" if header.length > 0
        header.clear
        if headerLine[1]
          header[:date] = Time.parse(headerLine[1])
        elsif defaultDate
          header[:date] = self.defaultDate
        else
          header[:date] = Time.now
        end
        header[:version] = headerLine[4] if headerLine[4]
        if headerLine[7]
          header[:author] = headerLine[7]
        else
          header[:author] = headerLine[9]
        end
        header[:mail] = headerLine[8] if headerLine[8]
        #Header in a RedHat format
        io_obj.puts "* " + header[:date].strftime("%a %b %d %Y") + " " + header[:author] + " <" + header[:mail] + "> " + header[:version]
        next
      end
      descriptionLine = @@easyfpmCLRegExp[:description].match(myLine)
      if descriptionLine
        io_obj.puts descriptionLine[1] + "- " + descriptionLine[3]
        next
      end

      #A line we can't analyse
      errorLines.push("  line " + lineNumber.to_s + " : " + myLine)
      returnCode=1
    end

    if errorLines.length > 0
      warn("Error : the followning(s) line(s) are not in easyfpm changelog format :")
      errorLines.each { |error| warn(error) }
    end
    return returnCode
  end #printRPM
  private :printRPM

  #(private) Write a DEB format changelog on an IO obj
  #Parameters:
  # io_obj : IO 
  def printDEB (io_obj=$stdout)
    returnCode = 0
    lineNumber = 0
    errorLines = []
    myChangelog = File.new(@changelog, "r")
    header = {}
    while (myLine = myChangelog.gets)
      lineNumber += 1
      commentLine = @@easyfpmCLRegExp[:comment].match(myLine)
      #If we have a comment, we ignore it
      next if commentLine
      ignoredLine = @@easyfpmCLRegExp[:ignored].match(myLine)
      #Line we have explicitely to ignore
      next if ignoredLine
      headerLine = @@easyfpmCLRegExp[:header].match(myLine)
      if headerLine
        #header line is found, we analyse it
        #if a header was here before, we display the debian style footer for the last one
        if header.length != 0
          io_obj.puts " -- " + header[:author] + " <" + header[:mail] + ">  " + header[:date].strftime("%a %d %b %Y %H:%M:%S %z")
          io_obj.puts ""
        end
        header.clear
        if headerLine[1]
          header[:date] = Time.parse(headerLine[1])
        elsif defaultDate
          header[:date] = self.defaultDate
        else
          header[:date] = Time.now
        end
        header[:version] = headerLine[4] if headerLine[4]
        if headerLine[7]
          header[:author] = headerLine[7]
        else
          header[:author] = headerLine[9]
        end
        header[:mail] = headerLine[8] if headerLine[8]
        #Debian style header
        io_obj.puts self.pkgname + " (" + header[:version] + ") " + self.distribution + "; urgency=" + self.urgency
        next
      end
      descriptionLine = @@easyfpmCLRegExp[:description].match(myLine)
      if descriptionLine
        if descriptionLine[1].length == 2
          io_obj.puts "  * " + descriptionLine[3]
        else
          io_obj.puts myLine
        end
        next
      end
  
      #A line we can't analyse
      errorLines.push("  line " + lineNumber.to_s + " : " + myLine)
      returnCode=1
    end
    if header.length != 0
      #We put the footer for the last header
      io_obj.puts " -- " +  header[:author] + " <" + header[:mail] + ">  " + header[:date].strftime("%a %d %b %Y %H:%M:%S %z")
    end
  
    if errorLines.length > 0
      $stderr.puts "Error : the followning(s) line(s) are not in easyfpm changelog format :"
      errorLines.each { |error| $stderr.puts(error) }
    end

    return returnCode
  end #printDEB
  private :printDEB

end
