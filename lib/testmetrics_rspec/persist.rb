class TestmetricsRspec
  # This sends the results to the Testmetrics server
  module Persist
    def self.call(results)
      unless results[:key] == "Unknown"
        Faraday.post do |req|
            req.url 'https://www.testmetrics.app/results'
            req.headers['Content-Type'] = 'application/json'
            req.body = results.to_json
        end
      end
      puts results
    end
  end
end
