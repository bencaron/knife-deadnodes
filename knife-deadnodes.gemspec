# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-deadnodes/version"

Gem::Specification.new do |s|
  s.name          = 'knife-deadnodes'
  s.version       = Knife::NodeDeadnodes::VERSION
  s.date          = '2012-11-28'
  s.summary       = "A plugin for Chef::Knife which displays nodes likely to be inactives."
  s.description   = s.summary
  s.authors       = ["Benoit Caron"]
  s.email         = ["bencaron@gmail.com"]
  s.homepage      = "https://github.com/bencaron/knife-deadnodes"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
