class MaintenanceMode
  def initialize(app)
    @app = app
  end

  def call(env)
    if maintenance_mode?
      return maintenance_response(env)
    else
      @app.call(env)
    end
  end

  private

  def maintenance_mode?
    ENV['IS_MAINTENANCE'] == '1'
  end

  def maintenance_response(env)
    headers = {
      'Content-Type' => 'application/json'
    }
    
    [503, headers, [maintenance_json.to_json]]
  end

  def maintenance_json
    {
      error_type: 'maintenance',
      message: I18n.t('errors.maintenance.message'),
      status: 503
    }
  end
end
