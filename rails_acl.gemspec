# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_acl/version'

Gem::Specification.new do |s|
  s.name        = "rails_acl"
  s.version     = RailsACL::VERSION
  s.authors     = ["Liam P. White"]
  s.email       = "example@example.com"
  s.summary     = "Extremely simple, performant authorization solution."
  s.description = "Yet another authorization solution."
  s.license     = "MIT"

  s.files       = `git ls-files`.split($/)
  s.require_paths = ["lib"]
end
