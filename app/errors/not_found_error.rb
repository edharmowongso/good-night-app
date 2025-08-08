class NotFoundError < CustomError
  def initialize(message = nil)
    super('not_found', message)
  end
end
