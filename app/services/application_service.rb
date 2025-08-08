class ApplicationService
  include TimeHelper
  
  class << self
    def call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end

  private

  def success(data = {})
    Result.new(success: true, data: data)
  end

  def failure(error, data = {})
    Result.new(success: false, error: error, data: data)
  end

  class Result
    attr_reader :data, :error

    def initialize(success:, data: {}, error: nil)
      @success = success
      @data = data
      @error = error
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end
end
