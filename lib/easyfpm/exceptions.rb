# The EASYFPM exceptions

#Raised if an unknown changelog format is asked
class EASYFPM::InvalidChangelogFormat < StandardError; end
#Raised if a needed argument for a package is missing
class EASYFPM::MissingArgument < StandardError; end
#Raised if a packaging label is asked and not configured
class EASYFPM::NoSuchSection < StandardError; end
