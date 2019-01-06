# The RSpec 2 formatter
class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  include ::TestmetricsRspec::Shared

  def stop
    @results = results do
      examples.map do |example|
        format(example.full_description,
               example.execution_result[:run_time],
               example.execution_result[:status].to_sym)
      end
    end

    super
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @results[:total_run_time] = run_time_in_microseconds(duration)
    TestmetricsRspec::Persist.call(@results)
    super
  end
end
