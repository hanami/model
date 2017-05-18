require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:all) do |task|
    task.pattern = FileList['spec/**/*_spec.rb']
  end

  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec:all'].invoke
  end
end

task default: 'spec:all'
