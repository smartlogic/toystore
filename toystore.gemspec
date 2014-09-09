# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "toy/version"

Gem::Specification.new do |s|
  s.name        = "toystore"
  s.version     = Toy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Geoffrey Dagley', 'John Nunemaker']
  s.email       = ['gdagley@gmail.com', 'nunemaker@gmail.com']
  s.homepage    = 'http://jnunemaker.github.com/toystore/'
  s.summary     = 'An object mapper for anything that can read, write and delete data'
  s.description = 'An object mapper for anything that can read, write and delete data'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'adapter',       '~> 0.7.0'
  s.add_dependency 'activemodel',   '~> 4.1'
  s.add_dependency 'activesupport', '~> 4.1'
  s.add_dependency 'simple_uuid',   '~> 0.2'
end
