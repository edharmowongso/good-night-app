redis_config = {
  host: ENV.fetch('REDIS_HOST', 'localhost'),
  port: ENV.fetch('REDIS_PORT', 6379),
  db: ENV.fetch('REDIS_DB', 0),
  reconnect_attempts: 3,
  connect_timeout: 5,
  read_timeout: 1,
  write_timeout: 1
}

# Initialize Redis connection
$redis = Redis.new(redis_config)

# Test Redis connection on startup
begin
  $redis.ping
  Rails.logger.info "✅ Redis connected successfully"
rescue Redis::CannotConnectError => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
  Rails.logger.error "💡 Make sure Redis server is running"
end
