# frozen_string_literal: true

require 'sidekiq'
require_relative 'config'


# sends reminding messages
class RemindWorker
  include Sidekiq::Worker

  def perform(work)
    sleep 5
    puts "Error #{work}"
  end
end
