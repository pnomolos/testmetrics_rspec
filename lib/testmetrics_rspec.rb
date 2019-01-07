require 'json'
require 'faraday'
require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require 'testmetrics_rspec/shared'
require 'testmetrics_rspec/persist'
require 'testmetrics_rspec/parallel_tests'

if Gem::Version.new(RSpec::Core::Version::STRING) >= Gem::Version.new('3')
  require 'testmetrics_rspec/rspec3'
else
  require 'testmetrics_rspec/rspec2'
end
