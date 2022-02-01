# Telegram BirthdayBot

## Description

This bot created to help peaple not to forget about upcoming Birthdays

## Requirements

- ruby v 3.0.2p102
- bundler 2.2.29

## Run Bot

```
$ ruby bin/main.rb
```

## Run mailing

```
$ bundle exec sidekiq -r ./workers/remind_worker.rb
```

### Jobs control

If you want to see mail logs do
```
$ rackup -r ./workers/config/config.ru
```
Then open localhost at port 9292

## App structure

- bin
  - main.rb
- lib
  - database.rb
  - state.rb
  - users.rb
  - keys.rb
  - development.db
- models
  - assets
    - inline_buttons.rb
    - keyboard_button.rb
  - dialogues
    - add_birthday.rb
    - edit_record.rb
    - notifikations.rb
  - listener.rb
  - response.rb
  - security.rb
  - callback_messages.rb
  - standart_messages.rb
- workers
  - config
    - config.rb
    - config.ru
    - sidekiq.yml
    - session.key
  - remind_worker.rb
- .gigignore
- .rubocop.yml
- Gemfile
- Gemfile.lock
- Readme.md