module SQRL
  module Check
    module Web
      class SerializeReporter
        def initialize(results)
          @results = results
        end

        attr_reader :results

        def to_h
          {
            'total_time' => results.total_time,
            'count' => results.count,
            'failures' => results.failures,
            'errors' => results.errors,
            'skips' => results.skips,
            'results' => results.results.map {|res|
              {
                'class_name' => res.class.name,
                'name' => res.name,
                'failures' => res.failures.map {|test|
                  {
                    'description' => test.to_s
                  }
                }
              }
            }
          }
        end

        def self.exception(exception)
          {
            'total_time' => 0,
            'count' => 1,
            'failures' => 0,
            'errors' => 1,
            'skips' => 0,
            'results' => [
              {
                'class_name' => exception.class.name,
                'name' => exception.message,
                'failures' => [
                  {
                    'description' => exception.backtrace.join("\n"),
                  }
                ]
              }
            ]
          }
        end

        def self.precondition_failed(message, description)
          {
            'total_time' => 0,
            'count' => 1,
            'failures' => 0,
            'errors' => 1,
            'skips' => 0,
            'results' => [
              {
                'class_name' => 'PreconditionFailed',
                'name' => message,
                'failures' => [
                  {
                    'description' => description,
                  }
                ]
              }
            ]
          }
        end
      end
    end
  end
end
