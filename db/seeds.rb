# db/seeds.rb
require 'open-uri'
require 'set'

puts "🗑️  Limpiando base de datos..."
# Borramos en orden para mantener integridad referencial
Item.delete_all
Sale.delete_all
# Limpiamos la tabla intermedia de géneros antes de borrar los discos
Disk.all.each { |d| d.genres.clear }
Disk.delete_all
Genre.delete_all
User.delete_all
Client.delete_all

# URL de imagen genérica para el seed
PLACEHOLDER_URL = "https://placehold.co/400x400/png"

# -----------------------------------------------------------------------------
# 1. CREACIÓN DE GÉNEROS
# -----------------------------------------------------------------------------
puts "🎵 Creando géneros musicales..."
genre_names = [ "Rock", "Pop", "Jazz", "Metal", "Indie", "Clásica", "Hip Hop", "Electrónica" ]
all_genres = genre_names.map do |name|
  Genre.find_or_create_by!(name: name)
end
puts "✅ #{Genre.count} géneros creados."

# -----------------------------------------------------------------------------
# 2. CREACIÓN DE DISCOS NUEVOS
# -----------------------------------------------------------------------------
puts "💿 Creando discos NUEVOS..."

20.times do |i|
  release_year = rand(1970..Time.current.year)

  disk = NewDisk.new(
    name: "Disco Nuevo #{i + 1}",
    description: "Edición de lujo del disco nuevo #{i + 1}.",
    author: [ "Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica" ].sample,
    unit_price: rand(15000..35000),
    stock: rand(5..50),
    format: [ "vinilo", "CD" ].sample,
    year: release_year       # solo el año de lanzamiento
  )

  # Asignar Género e Imagen
  disk.genres << all_genres.sample(rand(1..2))

  begin
    disk.save!
    print "."
  rescue StandardError => e
    puts "\n❌ Error NewDisk: #{e.message}"
  end
end

# -----------------------------------------------------------------------------
# 3. CREACIÓN DE DISCOS USADOS
# -----------------------------------------------------------------------------
puts "\n💿 Creando discos USADOS (Stock fijo en 1)..."

20.times do |i|
  release_year = rand(1970..Time.current.year)

  disk = UsedDisk.new(
    name: "Disco Usado #{i + 1}",
    description: "Disco usado en buen estado #{i + 1}.",
    author: [ "Nirvana", "Soda Stereo", "Charly García", "Radiohead" ].sample,
    unit_price: rand(5000..12000),
    stock: 1,
    format: [ "vinilo", "CD" ].sample,
    year: release_year       # solo el año de lanzamiento
  )

  disk.genres << all_genres.sample(rand(1..2))
  begin
    disk.save!
    print "."
  rescue StandardError => e
    puts "\n❌ Error NewDisk: #{e.message}"
  end
end

# -----------------------------------------------------------------------------
# 4. GENERACIÓN De Usuarios y Clientes
# -----------------------------------------------------------------------------
puts "\n 👤 --- Generando Usuarios y Clientes ---"
names = [ "Pepe", "Pedro", "Lucía", "Mateo", "Carla", "Julián", "María", "Diego", "Sofía", "Nicolás", "Valentina", "Agustín", "Camila", "Tomás", "Martina", "Bruno", "Julieta", "Lautaro", "Renata", "Franco" ]

lastnames = [ "González", "Martínez", "Fernández", "López", "Ramírez", "Torres", "Sánchez", "Duarte", "Herrera", "Pérez", "Álvarez", "Romero", "Benítez", "Vargas", "Castillo", "Navarro", "Medina", "Suárez", "Muñoz", "Rivas" ]

# Creamos al administrador
User.create!(email: "admin@example.com", password: "123456", name: names.sample, lastname: lastnames.sample, role: 0, is_active: true)

# Creamos gerentes
10.times do |i|
  User.create!(email: "gerente#{i + 1}@example.com", password: "123456", name: names.sample, lastname: lastnames.sample, role: 1, is_active: true)
end

# Creamos empleados
10.times do |i|
  User.create!(email: "empleado#{i + 1}@example.com", password: "123456", name: names.sample, lastname: lastnames.sample, role: 2, is_active: true)
end


type = [ "DNI", "PASAPORTE", "LE", "LC" ]
documents = Set.new

# generar 20 documentos únicos entre 5M y 50M
while documents.size < 20
  documents << rand(5_000_000..50_000_000)
end

documents = documents.to_a

20.times do |i|
  Client.create!(name: names.sample, lastname: lastnames.sample, email: "cliente#{i + 1}@example.com", document_type: type.sample, document_number: documents[i])
end

Client.create!(name: "Anónimo", lastname: "Anónimo", email: "anonimo@anonimo.com", document_type: "DNI", document_number: "0")

# -----------------------------------------------------------------------------
# 5. GENERACIÓN DE VENTAS E HISTORIAL
# -----------------------------------------------------------------------------
puts "\n📈 --- Generando Ventas Históricas ---"

# 1. Recuperamos usuarios y clientes REALES de la base de datos
users = User.all
clients = Client.all

# Validaciones por seguridad si la DB está vacía de usuarios/clientes
if users.empty?
  puts "⚠️ Creando usuario por defecto..."
  User.create!(email: "admin@seed.com", password: "password123", name: "Admin", lastname: "User", role: 1, is_active: true)
  users = User.all
end

if clients.empty?
  puts "⚠️ Creando cliente por defecto..."
  Client.create!(name: "Cliente", lastname: "Test", email: "cliente@test.com", document_type: "DNI", document_number: "111222333")
  clients = Client.all
end

# 2. Preparamos los discos para la venta
new_disks = NewDisk.all
# TRUCO: Guardamos los IDs de los usados en un array y los vamos sacando (.pop)
# Esto garantiza que un disco usado NUNCA se venda dos veces en el seed.
available_used_disk_ids = UsedDisk.pluck(:id).shuffle

puts "⏳ Creando ventas (últimos 60 días)..."

(0..60).each do |days_ago|
  fecha = Time.now - days_ago.days

  # Cantidad aleatoria de ventas por día (0 a 3)
  rand(0..3).times do
    # Elegimos vendedor y cliente al azar de los existentes
    seller = users.sample
    customer = clients.sample

    sale = Sale.create!(
      user_id: seller.id,       # Asignamos al usuario real
      customer_id: customer.id, # Asignamos al cliente real
      datetime: fecha,
      created_at: fecha,
      updated_at: fecha,
      total_amount: 0.0,
      deleted: false
    )

    sale_total = 0.0

    # A. Agregar Discos Nuevos (Pueden repetirse, stock > 1)
    if new_disks.any?
      new_disks.sample(rand(1..2)).each do |disk|
        qty = rand(1..2)
        price = disk.unit_price * qty

        Item.create!(
          sale: sale,
          disk: disk,
          units_sold: qty,
          price: price,
          description: disk.name,
          created_at: fecha,
          updated_at: fecha
        )
        sale_total += price
      end
    end

    # B. Agregar Disco Usado (Solo si quedan disponibles en la bolsa)
    # Probabilidad del 40% de que la venta incluya un usado
    if rand < 0.4 && available_used_disk_ids.any?
      used_id = available_used_disk_ids.pop # <--- LO SACAMOS DE LA LISTA
      disk_used = UsedDisk.find(used_id)

      price = disk_used.unit_price # Cantidad siempre es 1

      Item.create!(
        sale: sale,
        disk: disk_used,
        units_sold: 1,
        price: price,
        description: disk_used.name,
        created_at: fecha,
        updated_at: fecha
      )

      # Actualizamos el stock a 0 para ser consistentes
      disk_used.update_column(:stock, 0)

      sale_total += price
    end

    sale.update_columns(total_amount: sale_total)
  end
  print "."
end

puts "\n🚀 ¡Seed Finalizado! Datos listos para gráficos."
