require 'rake/testtask'

task :default => :spec

desc 'Run all the tests'
Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end