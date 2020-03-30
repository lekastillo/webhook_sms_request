# README

## SMS Twillio Service Usage
```ruby
  # para correr en webhook
  # 1- Instalar las gemas: `bundle install`
  # 2- Correr `rackup`
  rackup

  # para correr sidekiq
  bundle exec sidekiq -r ./workers/sms_request_worker.rb -C ./config/sidekiq.yml

```
---
