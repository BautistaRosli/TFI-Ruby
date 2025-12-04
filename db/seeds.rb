# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Eliminando datos previos..."
Disk.destroy_all
Genre.destroy_all

puts "Creando géneros..."
genre_names = [
  "Rock", "Pop", "Jazz", "Metal", "Hip-Hop",
  "Country", "Electronic", "R&B", "Reggae", "Soul",
  "Blues", "Classical", "Punk", "Folk", "Latin",
  "Funk", "Gospel", "Indie", "Alternative", "Experimental"
]
genres = genre_names.map { |g| Genre.find_or_create_by!(name: g) }

puts "Creando discos nuevos..."

20.times do |i|
  disk = NewDisk.create!(
    name: "Disco generico",
    description: "Descripción del disco #{i + 1}",
    author: ["Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica"].sample,
    unit_price: rand(5000..20000),
    stock: rand(1..20),
    format: ["vinilo", "CD"].sample,
    date_ingreso: Time.now - rand(1..100).days
  )
  disk.genres << genres.sample(2)
end

puts "Listo! Se crearon 20 NewDisks 🎵"

puts "Creando discos usados..."

20.times do |i|
  disk = UsedDisk.create!(
    name: "Disco usado generico",
    description: "Descripción del disco usado #{i + 1}",
    author: ["Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica"].sample,
    unit_price: rand(2000..12000),
    format: ["vinilo", "CD"].sample,
    date_ingreso: Time.now - rand(1..100).days
  )
  disk.genres << genres.sample(2)
end

puts "Listo! Se crearon 20 UsedDisks 🎶"