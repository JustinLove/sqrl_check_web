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
      end
    end
  end
end
