module InspectRequests
    extend self
  
    def inspect_requests(inject_headers: {})
      Testing::RequestInspectorMiddleware.log_requests!(inject_headers)
  
      yield
  
      # wait_for_all_requests
      Testing::RequestInspectorMiddleware.requests
    ensure
      Testing::RequestInspectorMiddleware.stop_logging!
    end
end
  