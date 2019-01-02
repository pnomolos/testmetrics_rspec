class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  def start(example_count)
    results = {
      key: ENV['TESTMETRICS_PROJECT_KEY'],
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

  def stop
    @results = {
      key: ENV['TESTMETRICS_PROJECT_KEY'],
      branch: git_branch,
      sha: git_sha,
      metadata: {
        ruby_version: RUBY_VERSION,
        ci_platform: ci_platform
      },
      tests: tests
    }
    super
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    # Send results in microseconds
    @results[:total_run_time] = (duration * 1_000_000).round(0)
    TestmetricsRspec::Persist.call(@results)
    super
  end

  private

  def tests
    examples.map do |example|
      {
        name: example.full_description.delete("\0").delete("\x01").delete("\e"),
        # Send results in microseconds
        total_run_time: (example.execution_result[:run_time] * 1_000_000).round(0),
        state: example.execution_result[:status].to_sym
      }
    end
  end

  BRANCH_VARS = ["TRAVIS_BRANCH", "CIRCLE_BRANCH", "CI_COMMIT_REF_NAME", "BRANCH_NAME"]
  def git_branch
    correct_var = BRANCH_VARS.find do |var| ENV[var] != nil end
    correct_var.nil? ? "Unknown" : ENV[correct_var]
  end

  SHA_VARS = ["TRAVIS_COMMIT", "CIRCLE_SHA1", "CI_COMMIT_SHA", "REVISION"]
  def git_sha
    correct_var = SHA_VARS.find do |var| ENV[var] != nil end
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
