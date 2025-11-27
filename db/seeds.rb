# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Eliminando discos previos..."
Disk.delete_all

puts "Creando discos nuevos..."

20.times do |i|
  NewDisk.create!(
    name: "Disco generico",
    description: "Descripción del disco #{i + 1}",
    author: ["Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica"].sample,
    unit_price: rand(5000..20000),
    stock: rand(1..20),
    category: ["Rock", "Pop", "Jazz", "Metal"].sample,
    format: ["vinilo", "CD"].sample,
    date_ingreso: Time.now - rand(1..100).days
  )
end

puts "Listo! Se crearon 20 NewDisks 🎵"

puts "Creando discos usados..."

20.times do |i|
  UsedDisk.create!(
    name: "Disco usado generico",
    description: "Descripción del disco usado #{i + 1}",
    author: ["Pink Floyd", "Queen", "AC/DC", "The Beatles", "Metallica"].sample,
    unit_price: rand(2000..12000),
    category: ["Rock", "Pop", "Jazz", "Metal"].sample,
    format: ["vinilo", "CD"].sample,
    date_ingreso: Time.now - rand(1..100).days
  )
end

puts "Listo! Se crearon 20 UsedDisks 🎶"