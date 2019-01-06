class TestmetricsRspec
  # This sends the results to the Testmetrics server or writes them to a file
  # if the tests are being run in parallel.
  module Persist
    class << self
      include ::TestmetricsRspec::Shared
      def call(results)
        puts results if currently_running_tests_for_this_gem?
        return if project_key_missing?(results)

        persist(results)
      end

      def persist(results)
        if running_in_parallel?
          return if ignore_results?(results)

          write_to_file(results)
        else
          post(results)
        end
      end

      def write_to_file(results)
        IO.write("results#{ENV['TEST_ENV_NUMBER']}.json", results.to_json)
      end

      def project_key_missing?(results)
        results[:key] == 'Unknown'
      end

      def running_in_parallel?
        ENV['PARALLEL_FORMAT'] == 'true'
      end

      def ignore_results?(results)
        results[:tests] == []
      end

      def currently_running_tests_for_this_gem?
        ENV['PRINT_TESTMETRICS_RESULTS'] == 'true'
      end
    end
  end
end
