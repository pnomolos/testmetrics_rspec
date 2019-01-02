# Doc
class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :start, :stop, :dump_summary

  # This sends the "start" message to testmetrics
  def start(notification)
    TestmetricsRspec::Persist.call({})
    super
  end

  def stop(notification)
    tests = notification.notifications.map do |test|
      {
        name: test.example.full_description,
        total_run_time: test.example.execution_result.run_time,
        state: test.example.execution_result.status
      }
    end

    @results = {
      total_run_time: nil,
      key: ENV['TESTMETRICS_PROJECT_KEY'],
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
    @results[:total_run_time] = notification.duration
    TestmetricsRspec::Persist.call(@results)
  end

  BRANCH_VARS = ["TRAVIS_BRANCH", "CIRCLE_BRANCH", "CI_COMMIT_REF_NAME", "BRANCH_NAME"]
  def git_branch
    correct_var = BRANCH_VARS.find do |var| ENV[var] != nil end
    correct_var.nil? ? nil : ENV[correct_var]
  end

  SHA_VARS = ["TRAVIS_COMMIT", "CIRCLE_SHA1", "CI_COMMIT_SHA", "REVISION"]
  def git_sha
    correct_var = SHA_VARS.find do |var| ENV[var] != nil end
    correct_var.nil? ? nil : ENV[correct_var]
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
