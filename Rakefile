# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
  measurement.output = 'measurement/report.txt'
end

Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 60
  verify.require_exact_threshold = false
end

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop verify_measurements]
