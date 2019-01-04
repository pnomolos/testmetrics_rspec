class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :start, :stop, :dump_summary

  # This sends the "start" message to testmetrics
  def start(notification)
    results = {
      key: ENV['TESTMETRICS_PROJECT_KEY'] || "Unknown",
      branch: git_branch,
      sha: git_sha,
      metadata: {
        ruby_version: RUBY_VERSION,
        ci_platform: ci_platform
      },
      tests: []
    }
    TestmetricsRspec::Persist.call(results)
    super
  end

  def stop(notification)
    tests = notification.notifications.map do |test|
      {
        name: test.example.full_description.delete("\0").delete("\x01").delete("\e"),
        # Send results in microseconds
        total_run_time: (test.example.execution_result.run_time * 1_000_000).round(0),
        state: test.example.execution_result.status
      }
    end

    @results = {
      key: ENV['TESTMETRICS_PROJECT_KEY'] || "Unknown",
      branch: git_branch,
      sha: git_sha,
      metadata: {
        ruby_version: RUBY_VERSION,
        ci_platform: ci_platform
      },
      tests: tests
    }
  end

  # This sends the "end" message to testmetrics
  def dump_summary(notification)
    # Send results in microseconds
    @results[:total_run_time] = (notification.duration * 1_000_000).round(0)
    TestmetricsRspec::Persist.call(@results)
  end

  BRANCH_VARS = ["TRAVIS_EVENT_TYPE", "CIRCLE_BRANCH", "CI_COMMIT_REF_NAME", "BRANCH_NAME"]
  def git_branch
    correct_var = BRANCH_VARS.find do |var| ENV[var] != nil && ENV[var] != "" end

    if correct_var == "TRAVIS_EVENT_TYPE"
      case ENV[correct_var]
      when "push"
        ENV["TRAVIS_BRANCH"]
      when "pull_request"
        ENV["TRAVIS_PULL_REQUEST_BRANCH"]
      end
    else
      correct_var.nil? ? "Unknown" : ENV[correct_var]
    end
  end

  SHA_VARS = ["TRAVIS_COMMIT", "CIRCLE_SHA1", "CI_COMMIT_SHA", "REVISION"]
  def git_sha
    correct_var = SHA_VARS.find do |var| ENV[var] != nil && ENV[var] != "" end
    correct_var.nil? ? "Unknown" : ENV[correct_var]
  end

  def ci_platform
    correct_var = SHA_VARS.find do |var| ENV[var] != nil end
    case correct_var
    when "TRAVIS_COMMIT"
      "Travis CI"
    when "CIRCLE_SHA1"
      "Circle CI"
    when "CI_COMMIT_SHA"
      "Gitlab CI"
    when "REVISION"
      "Semaphore CI"
    else
      "Unknown"
    end
  end
end
