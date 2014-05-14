# The EASYFPM exceptions

#Raised if an unknown changelog format is asked
class EASYFPM::InvalidChangelogFormat < StandardError; end
#Raised if a needed argument for a package is missing
class EASYFPM::MissingArgument < StandardError; end
#Raised if a packaging label is asked and not configured
class EASYFPM::NoSuchSection < StandardError; end
#Raised if a loop is detected with templates
class EASYFPM::LoopTemplateDetected < StandardError; end
#Raised if a template var is asked and not found
class EASYFPM::NoTemplateFound < StandardError; end
#Raised if a template var is not a string
class EASYFPM::InvalidTemplateType < StandardError; end
#Raised if a configuration is not validated
class EASYFPM::InvalidConfiguration < StandardError; end
#Raised if a problem is detected on the system
class EASYFPM::InvalidEnvironment < StandardError; end
