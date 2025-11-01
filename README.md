# TFI-Ruby
Ruby Version -> 3.4.0
Rails Version -> 8.0.0
Bundler
DB -> SQLite3 (archivo local en `storage/`)

Pasos al momoento de clonar:
- bundle install
- rails db:create db:migrate
- rails server

En caso de problemas con sqlite3:
gem uninstall sqlite3
bundle config set force_ruby_platform true
bundle install
Para compilar la gema desde el codigo fuente