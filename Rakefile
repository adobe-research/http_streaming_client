require "bundler/gem_tasks"
require 'rake/clean'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

CLEAN.include('test.log')
CLEAN.include('coverage')
