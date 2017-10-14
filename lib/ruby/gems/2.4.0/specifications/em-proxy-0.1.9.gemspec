# -*- encoding: utf-8 -*-
# stub: em-proxy 0.1.9 ruby lib

Gem::Specification.new do |s|
  s.name = "em-proxy".freeze
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ilya Grigorik".freeze]
  s.date = "2016-07-11"
  s.description = "EventMachine Proxy DSL".freeze
  s.email = ["ilya@igvita.com".freeze]
  s.executables = ["em-proxy".freeze]
  s.files = ["bin/em-proxy".freeze]
  s.homepage = "http://github.com/igrigorik/em-proxy".freeze
  s.rubyforge_project = "em-proxy".freeze
  s.rubygems_version = "2.6.11".freeze
  s.summary = "EventMachine Proxy DSL".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<em-http-request>.freeze, [">= 0"])
      s.add_development_dependency(%q<ansi>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<posix-spawn>.freeze, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<em-http-request>.freeze, [">= 0"])
      s.add_dependency(%q<ansi>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<posix-spawn>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<em-http-request>.freeze, [">= 0"])
    s.add_dependency(%q<ansi>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<posix-spawn>.freeze, [">= 0"])
  end
end
