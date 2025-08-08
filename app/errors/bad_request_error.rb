class BadRequestError < CustomError
  def initialize(message = nil)
    super('bad_request', message)
  end
end
