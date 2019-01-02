# This sends the results to the Testmetrics server
module TestmetricsRspec::Persist
  def self.call(results)
    puts results
  end
end
