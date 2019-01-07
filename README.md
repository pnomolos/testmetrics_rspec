# Testmetrics RSpec [![Build Status](https://travis-ci.org/Testmetrics/testmetrics_rspec.svg?branch=master)](https://travis-ci.org/Testmetrics/testmetrics_rspec) [![Gem version](http://img.shields.io/gem/v/testmetrics_rspec.svg)](https://rubygems.org/gems/testmetrics_rspec)

The official [RSpec][rspec] 2 & 3 client for [Testmetrics](https://www.testmetrics.app). This client collects data about your RSpec test suites after being run in CI and sends that data to Testmetrics so you can gain valuable insights about your test suite.

## Usage

Add it to your Gemfile in the same groups as rspec.

```ruby
group :test do
  gem "rspec"
  gem "testmetrics_rspec"
end
```

Add `TestmetricsRspec` as a formatter in [your `.rspec` file][rspec-file]:

```sh
--format TestmetricsRspec
```

  [bundler]: https://bundler.io
  [rspec-file]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/configuration/read-command-line-configuration-options-from-files

In order for the metrics to be sent to Testmetrics, you must have your
Testmetrics Project Key set in the `TESTMETRICS_PROJECT_KEY` environment
variable in your CI environment. If this environment variable isn't set, the
collected metrics for your CI run will be discarded.

This key should be kept private and not exposed to the public.

### Additional setup for using with the `parallel_tests` gem

If you are running your tests in parallel in CI with the `parallel_tests` gem,
there are additional steps you need to take to start collecting metrics in CI.

First, do the steps listed above.

If you have a `.rspec_parallel` file, also add `TestmetricsRspec` as a formatter
there:

```sh
--format TestmetricsRspec
```

Then, add the following task to your `Rakefile`

```ruby
require 'testmetrics_rspec'
task :testmetrics_parallel_rspec do
  TestmetricsRspec::ParallelTests.run()
end
```

Lastly, you'll need to change your CI script to use that rake task to run your
tests. `rake testmetrics_parallel_rspec` (or whatever you name that task - it
can be whatever you want) is just a wrapper around running `parallel_rspec`, so
all command line options that you would normally give work just the same. You
just replace `parallel_rspec` with `rake testmetrics_parallel_rspec` and it will
work.

## License

`TestmetricsRspec` is offered under the MIT license. For the full license
text see [LICENSE](https://github.com/testmetrics/testmetrics_rspec/blob/master/LICENSE).
