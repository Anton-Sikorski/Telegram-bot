# frozen_string_literal: true

class BirthdayBot
  # This module assigned to creating InlineKeyboardButton
  module InlineButton
    GET_BIRTHDAY = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Дни рождения', callback_data: 'birthday')
    SET_BIRTHDAY = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Добавить запись',
                                                                  callback_data: 'set_birthday')
    CONFIRM_SAVE = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Да', callback_data: 'save_data')
    DECLINE_SAVE = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Нет', callback_data: 'reset')
    CHECK_DATES = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'А когда праздники?',
                                                                 callback_data: 'check_dates')
  end
end
