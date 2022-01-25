# frozen_string_literal: true

class BirthdayBot
  # takes care about messages
  module Listener
    attr_accessor :message, :bot

    def catch_new_message(message, bot)
      self.message = message
      self.bot = bot

      return false if Security.message_too_far

      case self.message
      when Telegram::Bot::Types::CallbackQuery
        CallbackMessages.process
      when Telegram::Bot::Types::Message
        StandardMessages.process
      end
    end

    module_function(
      :catch_new_message,
      :message,
      :message=,
      :bot,
      :bot=
    )
  end
end
