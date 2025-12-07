# TFI-Ruby
Ruby Version -> 3.4.0
Rails Version -> 8.0.0
Bundler
DB -> SQLite3 (archivo local en `storage/`)

Pasos al momento de clonar:
- bundle install
- rails db:create db:migrate
- rails server
- rails generate wicked_pdf o rails g wicked_pdf (Crea los archivos de configuración e inicialización para la gema WickedPDF.)

En caso de problemas con sqlite3:
gem uninstall sqlite3
bundle config set force_ruby_platform true
bundle install
Para compilar la gema desde el codigo fuente

Aclaración de uso en cuanto usuarios y clientes:
Hay un administrador, sus credenciales son: admin@example.com, password 123456
Hay 10 empleados, sus credenciales son: empleado(numero del 1 al 10)@example.com, password 123456
Hay 10 gerente, sus credenciales son: gerente(numero del 1 al 10)@example.com, password 123456

Hay 20 clientes cargados
Hay un clientes definido como anónimo en caso de que un cliente real no quiera dejar sus datos, tipo de documento: DNI numero de documento: 0

