# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{deltoid_delta}
  s.version = "0.0.14"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Niles"]
  s.date = %q{2010-12-01}
  s.description = %q{Delta indexing plugin for Thinking Sphinx that sets a reindex flag in memcached whenever a model needs to be reindexed.
  It is expected to be used along with the Deltoid daemon, which polls memcached and rebuilds indices whenever the reindex 
  flags are set.}
  s.email = %q{christian@nerdyc.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "deltoid_delta.gemspec",
    "lib/deltoid_delta.rb",
    "lib/deltoid_delta/tasks.rb",
    "spec/deltoid_delta_spec.rb",
    "spec/spec_helper.rb",
    "vendor/deltoid_daemon/.gitignore",
    "vendor/deltoid_daemon/Gemfile",
    "vendor/deltoid_daemon/Gemfile.lock",
    "vendor/deltoid_daemon/README.md",
    "vendor/deltoid_daemon/Rakefile",
    "vendor/deltoid_daemon/bin/deltoid",
    "vendor/deltoid_daemon/config/arguments.rb",
    "vendor/deltoid_daemon/config/boot.rb",
    "vendor/deltoid_daemon/config/environment.rb",
    "vendor/deltoid_daemon/config/environments/development.rb",
    "vendor/deltoid_daemon/config/environments/production.rb",
    "vendor/deltoid_daemon/config/environments/staging.rb",
    "vendor/deltoid_daemon/config/environments/test.rb",
    "vendor/deltoid_daemon/config/post-daemonize/readme",
    "vendor/deltoid_daemon/config/pre-daemonize/cron.rb",
    "vendor/deltoid_daemon/config/pre-daemonize/readme",
    "vendor/deltoid_daemon/lib/deltoid.rb",
    "vendor/deltoid_daemon/libexec/deltoid-daemon.rb",
    "vendor/deltoid_daemon/log/.gitkeep",
    "vendor/deltoid_daemon/script/console",
    "vendor/deltoid_daemon/script/destroy",
    "vendor/deltoid_daemon/script/generate",
    "vendor/deltoid_daemon/spec/deltoid_spec.rb",
    "vendor/deltoid_daemon/spec/spec_helper.rb",
    "vendor/deltoid_daemon/tasks/rspec.rake"
  ]
  s.homepage = %q{http://github.com/satisfaction/deltoid_delta}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Delta indexing plugin for Thinking Sphinx that inserts and entry in memcached whenever a model needs reindexing.}
  s.test_files = [
    "spec/deltoid_delta_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<ts-datetime-delta>, ["~> 1.0.2"])
      s.add_runtime_dependency(%q<daemon-kit>, ["= 0.1.8.1"])
      s.add_runtime_dependency(%q<rufus-scheduler>, [">= 2.0.3"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_dependency(%q<ts-datetime-delta>, ["~> 1.0.2"])
      s.add_dependency(%q<daemon-kit>, ["= 0.1.8.1"])
      s.add_dependency(%q<rufus-scheduler>, [">= 2.0.3"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    s.add_dependency(%q<ts-datetime-delta>, ["~> 1.0.2"])
    s.add_dependency(%q<daemon-kit>, ["= 0.1.8.1"])
    s.add_dependency(%q<rufus-scheduler>, [">= 2.0.3"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.1.0"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

