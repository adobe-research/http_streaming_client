require "bundler/gem_tasks"
require 'rake/clean'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

CLEAN.include('test.log')
CLEAN.include('coverage')

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, :features, 'coveralls:push']
