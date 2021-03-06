# -*- encoding: utf-8 -*-
# stub: iron_core 1.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "iron_core"
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Kirilenko", "Iron.io, Inc"]
  s.date = "2014-05-22"
  s.description = "Core library for Iron products"
  s.email = ["info@iron.io"]
  s.homepage = "https://github.com/iron-io/iron_core_ruby"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8")
  s.rubygems_version = "2.1.11"
  s.summary = "Core library for Iron products"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest>, [">= 2.6.4"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rest>, [">= 2.6.4"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest>, [">= 2.6.4"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
