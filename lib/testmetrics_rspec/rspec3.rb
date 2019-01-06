# The RSpec 3 formatter
class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :start, :stop, :dump_summary
  include ::TestmetricsRspec::Shared

  def stop(notification)
    @results = results do
      notification.notifications.map do |test|
        format(test.example.full_description,
               test.example.execution_result.run_time,
               test.example.execution_result.status)
      end
    end
  end

  def dump_summary(notification)
    @results[:total_run_time] = run_time_in_microseconds(notification.duration)
    TestmetricsRspec::Persist.call(@results)
  end
end
