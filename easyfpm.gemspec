Gem::Specification.new do |spec|
  spec.name        = 'easyfpm'
  spec.version     = '0.1.0.pre'
  spec.date        = '2014-05-15'
  spec.summary     = "Wrapper for fpm"
  spec.description = <<-EOF
  Simplify packaging with fpm by using config files.
  The aim is to have 1 config file to create many packages for one script module (deb, rpm).
  For the moment, the source MUST be a directory, but this tool can manage a changelog format and also mapping files if the module tree is different from the targeted (deployment) tree.
EOF
  spec.authors     = ["Erwan SEITE"]
  spec.email       = 'wanix.fr@gmail.com'
  spec.test_files  = Dir.glob('tests/test-*.rb')
  spec.files       = Dir.glob('lib/*.rb')
  spec.files      += Dir.glob('lib/easyfpm/*.rb')
  spec.executables << 'easyfpm'
  spec.executables << 'easyfpm-translatecl'
  spec.homepage    = 'https://github.com/wanix/easyfpm'
  spec.license     = 'GPLv2'
  #spec.metadata    = { "issue_tracker" => "https://github.com/wanix/easyfpm/issues" }
  spec.extra_rdoc_files  = [ 'README.md', 'LICENSE' , 'THANKS' ]
  spec.extra_rdoc_files += Dir.glob('doc/samples/*.cfg')
  spec.extra_rdoc_files += Dir.glob('doc/samples/*.conf')
  spec.extra_rdoc_files += Dir.glob('doc/samples/install_scripts/*')
  spec.required_ruby_version = '>= 1.9.1'
  spec.add_runtime_dependency 'ptools', '>=1.2.4'
  spec.add_runtime_dependency 'fpm', '>=1.1.0'
  spec.add_runtime_dependency 'unixconfigstyle', '>=1.0.0'
end
