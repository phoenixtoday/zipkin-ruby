module ZipkinTracer

  # Useful methods on the Application we are instrumenting
  class Application
    # If the request is not valid for this service, we do not what to trace it.
    def self.routable_request?(path_info, http_method)
      return true unless defined?(Rails) # If not running on a Rails app, we can't verify if it is invalid
      Rails.application.routes.recognize_path(path_info, method: http_method)
      true
    rescue ActionController::RoutingError
      false
    end

    def self.logger
      if defined?(Rails) # If we happen to be inside a Rails app, use its logger
        Rails.logger
      else
        Logger.new(STDOUT)
      end
    end

    def self.config(app)
      if app.respond_to?(:config) && app.config.respond_to?(:zipkin_tracer)
        app.config.zipkin_tracer
      else
        {}
      end
    end
  end
end
