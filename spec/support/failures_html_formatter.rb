RSpec::Support.require_rspec_core "formatters/base_text_formatter"
RSpec::Support.require_rspec_core "formatters/html_printer"

module RSpec
  module Core
    module Formatters
      # @private
      class FailuresHtmlFormatter < BaseFormatter
        Formatters.register self, :start, :example_group_started, :start_dump,
                            :example_started, :example_passed, :example_failed,
                            :example_pending, :dump_summary

        def initialize(output)
          super(output)
          @failed_examples = []
          @header_red = nil
          @printer = HtmlPrinter.new(output)
        end

        def start(notification)
        end

        def example_group_started(notification)
        end

        def example_group_passed(notification)
        end

        def start_dump(_notification)
        end

        def example_started(_notification)
        end

        def example_passed(passed)
        end

        def example_failed(failure)
          example = failure.example
          @output << "<div style='background-color:red; padding:8px;margin:4px;'>"\
                     "#{example.full_description}"\
                     "<br/> #{example.location}"
          @output << "<br/> #{example.execution_result.exception}"
          @output << "</div>"

          @output.flush
        end

        def example_pending(pending)
        end

        def dump_summary(summary)
        end

      end
    end
  end
end
