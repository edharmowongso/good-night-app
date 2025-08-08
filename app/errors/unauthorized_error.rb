class UnauthorizedError < CustomError
  def initialize(message = nil)
    super('unauthorized', message)
  end
end
