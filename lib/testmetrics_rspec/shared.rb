class TestmetricsRspec < RSpec::Core::Formatters::BaseFormatter
  # Shared stuff between formatters
  module Shared
    def start(notification)
      TestmetricsRspec::Persist.call(starting_results)
      super
    end

    def post(results)
      Faraday.post do |req|
        req.url 'https://www.testmetrics.app/results'
        req.headers['Content-Type'] = 'application/json'
        req.body = results.to_json
      end
    end

    def format(description, run_time, status)
      {
        name: description.delete("\0").delete("\x01").delete("\e"),
        total_run_time: run_time_in_microseconds(run_time),
        state: status
      }
    end

    def starting_results
      results { [] }
    end

    def results
      {
        key: ENV['TESTMETRICS_PROJECT_KEY'] || 'Unknown',
        branch: git_branch,
        sha: git_sha,
        metadata: {
          ruby_version: RUBY_VERSION,
          ci_platform: ci_platform
        },
        tests: yield
      }
    end

    def run_time_in_microseconds(time)
      (time * 1_000_000).round(0)
    end

    BRANCH_VARS = %w[
      TRAVIS_EVENT_TYPE
      CIRCLE_BRANCH
      CI_COMMIT_REF_NAME
      BRANCH_NAME
    ].freeze
    def git_branch
      correct_var = correct_var(BRANCH_VARS)

      if correct_var == 'TRAVIS_EVENT_TYPE'
        travis_branch(correct_var)
      else
        correct_var.nil? ? 'Unknown' : ENV[correct_var]
      end
    end

    def travis_branch(var)
      case ENV[var]
      when 'push'
        ENV['TRAVIS_BRANCH']
      when 'pull_request'
        ENV['TRAVIS_PULL_REQUEST_BRANCH']
      end
    end

    SHA_VARS = %w[TRAVIS_COMMIT CIRCLE_SHA1 CI_COMMIT_SHA REVISION].freeze
    def git_sha
      correct_var = correct_var(SHA_VARS)
      correct_var.nil? ? 'Unknown' : ENV[correct_var]
    end

    def ci_platform
      case correct_var(SHA_VARS)
      when 'TRAVIS_COMMIT' then 'Travis CI'
      when 'CIRCLE_SHA1' then 'Circle CI'
      when 'CI_COMMIT_SHA' then 'Gitlab CI'
      when 'REVISION' then 'Semaphore CI'
      else 'Unknown'
      end
    end

    def correct_var(vars)
      vars.find { |var| !ENV[var].nil? && ENV[var] != '' }
    end
  end
end
