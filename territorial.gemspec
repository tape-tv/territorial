# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'territorial/version'

Gem::Specification.new do |spec|
  spec.name          = "territorial"
  spec.version       = Territorial::VERSION
  spec.authors       = ["Christof Dorner", "Matt Patterson"]
  spec.email         = ["christof@chdorner.com", "matt@reprocessed.org"]

  spec.summary       = %q{Work with lists of country codes and shorthand regions ('EU')}
  spec.description   = <<-EOD
If you have to work with lists of ISO 3166-1 alpha-2 country codes that
sometimes include fake codes that should be expanded to a longer list, e.g.
'EU', or if you have to deal with lists of territory metadata like 'EU -FR'
then territorial will help. It defines some commonly seen default expansion
codes, and allows you to correctly expand a string like 'EU -FR' into an
array of 2-letter country codes
  EOD
  spec.homepage      = "https://github.com/tape-tv/territorial"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.3.0'
end
