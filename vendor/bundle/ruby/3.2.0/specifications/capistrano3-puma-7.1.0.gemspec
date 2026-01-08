# -*- encoding: utf-8 -*-
# stub: capistrano3-puma 7.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano3-puma".freeze
  s.version = "7.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Abdelkader Boudih".freeze]
  s.date = "1980-01-02"
  s.description = "Puma integration for Capistrano 3".freeze
  s.email = ["Terminale@gmail.com".freeze]
  s.homepage = "https://github.com/seuros/capistrano-puma".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Puma integration for Capistrano".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<capistrano>.freeze, ["~> 3.7"])
  s.add_runtime_dependency(%q<capistrano-bundler>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<puma>.freeze, [">= 6.1", "< 8.0"])
end
