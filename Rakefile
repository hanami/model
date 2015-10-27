require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs.push 'test'
end

Rake::TestTask.new do |t|
  t.name = 'unit'
  t.test_files = Dir['test/**/*_test.rb'].reject do |path| 
    path.include?('/integration')
  end
  t.libs.push 'test'
end

Rake::TestTask.new do |t|
  t.name = 'integration'
  t.pattern = 'test/integration/**/*_test.rb'
  t.libs.push 'test'
end

namespace :test do
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].invoke
  end

  desc 'Runs only unit tests'
  task :unit do
    Rake::Task['unit'].invoke
  end

  desc 'Run only integration tests'
  task :integration do
    Rake::Task['integration'].invoke
  end
end

task default: :test
