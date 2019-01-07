class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  # This is a wrapper around running RSpec with the `parallel_tests` gem
  class ParallelTests
    class << self
      include ::TestmetricsRspec::Shared

      def run
        key = ENV['TESTMETRICS_PROJECT_KEY']

        post(starting_results) unless key.nil?

        ENV['PARALLEL_FORMAT'] = 'true'
        system("parallel_rspec #{ARGV[1..-1].join(' ')}")
        ENV['PARALLEL_FORMAT'] = nil

        send_end_results unless key.nil?
      end

      def send_end_results
        results = Dir.glob('results*.json').each_with_object([]) do |path, acc|
          acc << JSON.parse(IO.read(path))
          FileUtils.rm(path)
        end

        post(combined(results))
      end

      def combined(results)
        start = results.pop

        results.each_with_object(start) do |result, acc|
          acc['tests'] = acc['tests'] + result['tests']
          acc['total_run_time'] = acc['total_run_time'] +
                                  result['total_run_time']
        end
      end
    end
  end
end
