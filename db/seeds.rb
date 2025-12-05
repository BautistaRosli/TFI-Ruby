# db/seeds.rb
require 'open-uri'

puts "🗑️  Limpiando base de datos..."
# Borramos en orden para mantener integridad
Item.delete_all
Sale.delete_all
# Borramos la tabla intermedia y luego los modelos
Disk.all.each { |d| d.genres.clear }
Disk.delete_all
Genre.delete_all

# URL de imagen genérica
PLACEHOLDER_URL = "https://placehold.co/400x400/png"

# -----------------------------------------------------------------------------
# 1. CREACIÓN DE GÉNEROS (NUEVA LÓGICA)
# -----------------------------------------------------------------------------
puts "🎵 Creando géneros musicales..."
genre_names = [ "Rock", "Pop", "Jazz", "Metal", "Indie", "Clásica", "Hip hop", "Electrónica" ]
all_genres = genre_names.map do |name|
  Genre.find_or_create_by!(name: name)
end
puts "✅ #{Genre.count} géneros creados."

# -----------------------------------------------------------------------------
# 2. CREACIÓN DE DISCOS NUEVOS
# -----------------------------------------------------------------------------
puts "💿 Creando discos NUEVOS (con imágenes y géneros)..."

20.times do |i|
  disk = NewDisk.new(
    name: "Disco Nuevo #{i + 1}",
    description: "Edición de lujo del disco nuevo #{i + 1}.",
    author: [ "Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica" ].sample,
    unit_price: rand(15000..35000),
    stock: rand(5..50), # Stock variado para nuevos
    format: [ "vinilo", "CD" ].sample,
    date_ingreso: Time.now - rand(1..100).days
  )

  # ASIGNAR GÉNERO (Relación has_and_belongs_to_many)
  # Le asignamos 1 o 2 géneros al azar
  disk.genres << all_genres.sample(rand(1..2))

  # ADJUNTAR IMAGEN
  begin
    file = URI.open(PLACEHOLDER_URL)
    disk.cover.attach(io: file, filename: "new_cover_#{i}.png", content_type: "image/png")
    disk.save!
    print "."
  rescue StandardError => e
    puts "\n❌ Error al crear NewDisk #{i+1}: #{e.message}"
  end
end
puts "\n✅ 20 NewDisks creados."

# -----------------------------------------------------------------------------
# 3. CREACIÓN DE DISCOS USADOS
# -----------------------------------------------------------------------------
puts "💿 Creando discos USADOS (Stock fijo en 1)..."

20.times do |i|
  disk = UsedDisk.new(
    name: "Disco Usado #{i + 1}",
    description: "Disco usado en buen estado #{i + 1}.",
    author: [ "Nirvana", "Soda Stereo", "Charly García", "Radiohead" ].sample,
    unit_price: rand(5000..12000),
    stock: 1, # <--- REGLA DE NEGOCIO: SIEMPRE 1
    format: [ "vinilo", "CD" ].sample,
    date_ingreso: Time.now - rand(1..100).days
  )

  # ASIGNAR GÉNERO
  disk.genres << all_genres.sample(rand(1..2))

  # ADJUNTAR IMAGEN
  begin
    file = URI.open(PLACEHOLDER_URL)
    disk.cover.attach(io: file, filename: "used_cover_#{i}.png", content_type: "image/png")
    disk.save!
    print "."
  rescue StandardError => e
    puts "\n❌ Error al crear UsedDisk #{i+1}: #{e.message}"
  end
end
puts "\n✅ 20 UsedDisks creados."
