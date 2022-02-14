# frozen_string_literal: true

require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

require 'securerandom'
require 'sidekiq/web'

File.open('.session.key', 'w') { |f| f.write(SecureRandom.hex(32)) }
use Rack::Session::Cookie, secret: File.read('.session.key'), same_site: true, max_age: 86_400
run Sidekiq::Web
