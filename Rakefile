# frozen_string_literal: true

require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "hanami/devtools/rake_tasks"

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = FileList["spec/**/*_spec.rb"]
  end
end

task default: "spec:unit"
