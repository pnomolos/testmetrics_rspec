require 'pty'
require 'testmetrics_rspec'

RSpec.describe TestmetricsRspec do
  EXAMPLE_DIR = File.expand_path('../example', __dir__)

  def run_tests
    sio = StringIO.new
    args = ['bundle', 'exec', 'rspec', '--format', 'TestmetricsRspec']
    begin
      PTY.spawn(*args, chdir: EXAMPLE_DIR) do |r, w, pid|
        begin
          r.each_line { |l| sio.puts(l) }
        rescue Errno::EIO
        ensure
          ::Process.wait pid
        end
      end
    rescue PTY::ChildExited
    end
    sio.string
  end

  it 'sends everything we need to the server' do
    result = run_tests
    result = eval(result)
    expect(result[:key]).to be_a(String)
    expect(result[:branch]).to be_a(String)
    expect(result[:sha]).to be_a(String)
    expect(result[:metadata][:ruby_version]).to be_a(String)
    expect(result[:metadata][:ci_platform]).to be_a(String)
    expect(result[:total_run_time]).to be > 10

    result[:tests].each do |test|
      expect(test[:name]).to be_a(String)
      expect(test[:total_run_time]).to be > 10
      expect([:passed, :failed, :pending]).to include(test[:state])
    end
  end
end
