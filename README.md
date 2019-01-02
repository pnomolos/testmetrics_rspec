# Testmetrics RSpec [![Build Status](https://travis-ci.org/Testmetrics/testmetrics_rspec.svg?branch=master)](https://travis-ci.org/Testmetrics/testmetrics_rspec) [![Gem version](http://img.shields.io/gem/v/testmetrics_rspec.svg)](https://rubygems.org/gems/testmetrics_rspec)

The official [RSpec][rspec] 2 & 3 client for [Testmetrics](https://www.testmetrics.app). This client collects data about your RSpec test suites after being run in CI and sends that data to Testmetrics so you can gain valuable insights about your test suite.

## Usage

Install the gem:

```sh
gem install testmetrics_rspec
```

Use it:

```sh
rspec --format TestmetricsRspec 
```

You can use it in combination with other [formatters][rspec-formatters], too:

```sh
rspec --format progress --format TestmetricsRspec
```

  [rspec-formatters]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/formatters

In order for the metrics to be send to Testmetrics, you must have your
Testmetrics Project Key set in the "TESTMETRICS_PROJECT_KEY" environment
variable in your CI environment. If this environment variable isn't set, the
collected metrics for your CI run will be discarded. This key should be kept
private and not exposed to the public.

### Using in your project with Bundler

Add it to your Gemfile if you're using [Bundler][bundler]. Put it in the same groups as rspec.

```ruby
group :test do
  gem "rspec"
  gem "testmetrics_rspec"
end
```

Put the same arguments as the commands above in [your `.rspec`][rspec-file]:

```sh
--format TestmetricsRspec
```

  [bundler]: https://bundler.io
  [rspec-file]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/configuration/read-command-line-configuration-options-from-files

## License

`TestmetricsRspec` is offered under the MIT license. For the full license
text see [LICENSE](https://github.com/testmetrics/testmetrics_rspec/blob/master/LICENSE).
