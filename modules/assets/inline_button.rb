# frozen_string_literal: true

class BirthdayBot
  # This module assigned to creating InlineKeyboardButton
  module InlineButton
    GET_BIRTHDAY = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Дни рождения', callback_data: 'birthdays')
  end
end
