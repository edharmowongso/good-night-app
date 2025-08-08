class Api::V1::HealthController < Api::V1::BaseController
  skip_before_action :set_current_user

  def index
    health_status = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      database: database_status,
      cache: cache_status,
      redis: redis_status
    }
    
    render json: health_status
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue => e
    'disconnected'
  end

  def cache_status
    Rails.cache.write('health_check', 'ok', expires_in: 1.minute)
    Rails.cache.read('health_check') == 'ok' ? 'connected' : 'disconnected'
  rescue => e
    'disconnected'
  end

  def redis_status
    $redis&.ping == 'PONG' ? 'connected' : 'disconnected'
  rescue => e
    'disconnected'
  end
end
