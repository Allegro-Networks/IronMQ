# -*- encoding: utf-8 -*-
# stub: iron_mq 5.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "iron_mq"
  s.version = "5.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yury Yantsevich", "Travis Reeder"]
  s.date = "2014-02-18"
  s.description = "Ruby client for IronMQ by www.iron.io"
  s.email = ["yury@iron.io", "travis@iron.io"]
  s.homepage = "https://github.com/iron-io/iron_mq_ruby"
  s.licenses = ["BSD-2-Clause"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8")
  s.rubygems_version = "2.1.11"
  s.summary = "Ruby client for IronMQ by www.iron.io"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<iron_core>, [">= 0.5.1"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<beanstalk-client>, [">= 0"])
      s.add_development_dependency(%q<uber_config>, [">= 0"])
      s.add_development_dependency(%q<typhoeus>, [">= 0.5.4"])
      s.add_development_dependency(%q<net-http-persistent>, [">= 0"])
      s.add_development_dependency(%q<quicky>, [">= 0"])
      s.add_development_dependency(%q<iron_worker_ng>, [">= 0"])
      s.add_development_dependency(%q<go>, [">= 0"])
    else
      s.add_dependency(%q<iron_core>, [">= 0.5.1"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<beanstalk-client>, [">= 0"])
      s.add_dependency(%q<uber_config>, [">= 0"])
      s.add_dependency(%q<typhoeus>, [">= 0.5.4"])
      s.add_dependency(%q<net-http-persistent>, [">= 0"])
      s.add_dependency(%q<quicky>, [">= 0"])
      s.add_dependency(%q<iron_worker_ng>, [">= 0"])
      s.add_dependency(%q<go>, [">= 0"])
    end
  else
    s.add_dependency(%q<iron_core>, [">= 0.5.1"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<beanstalk-client>, [">= 0"])
    s.add_dependency(%q<uber_config>, [">= 0"])
    s.add_dependency(%q<typhoeus>, [">= 0.5.4"])
    s.add_dependency(%q<net-http-persistent>, [">= 0"])
    s.add_dependency(%q<quicky>, [">= 0"])
    s.add_dependency(%q<iron_worker_ng>, [">= 0"])
    s.add_dependency(%q<go>, [">= 0"])
  end
end
