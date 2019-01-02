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
    run_tests
  end
end
