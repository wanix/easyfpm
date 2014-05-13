# The EASYFPM exceptions

#Raised if an unknown changelog format is asked
class EASYFPM::InvalidChangelogFormat < StandardError; end
class EASYFPM::MissingArgument < StandardError; end
class EASYFPM::NoSuchSection < StandardError; end
