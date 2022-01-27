# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-scheduler'
require_relative '../lib/database'
require_relative '../lib/keys'
require_relative 'config/config'


# sends reminding messages
class RemindWorker
  include Sidekiq::Worker

  def perform
    database = Database.setup
    db = Database.select(276510840)
    sleep 5
    pp db
  end
end
