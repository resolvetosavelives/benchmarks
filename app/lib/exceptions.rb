module Exceptions
  class InvalidDiseasesError < StandardError
    attr_reader :status, :error, :message

    def initialize(_error = nil, _status = nil, _message = nil)
      @error = _error || 422
      @status = _status || :unprocessable_entity
      @message = _message || "One or more of the diseases selected is invalid. Please go back to the Get Started page to start over."
    end
  end
end