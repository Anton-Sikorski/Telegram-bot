# frozen_string_literal: true

class BirthdayBot
  # This module assigned to creating InlineKeyboardButton
  module InlineButton
    CONFIRM_SAVE = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Да', callback_data: 'save_data')
    DECLINE_SAVE = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Нет', callback_data: 'reset')
    EDIT_NAME =  Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Имя', callback_data: 'edit_name')
    EDIT_DATE =  Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Дату', callback_data: 'edit_date')
    DELETE_RECORD = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Удалить запись',
                                                                   callback_data: 'delete_record')
    CONFIRM_EDIT = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Да', callback_data: 'confirm_edit')
    DECLINE_EDIT = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Нет', callback_data: 'reset')
  end
end
