require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--colour']
  spec.pattern = 'spec/**/*_spec.rb'
end