require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

if Gem::Version.new(RSpec::Core::Version::STRING) >= Gem::Version.new('3')
  require 'testmetrics_rspec/rspec3'
else
  require 'testmetrics_rspec/rspec2'
end

require 'testmetrics_rspec/persist'
