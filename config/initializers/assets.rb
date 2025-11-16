# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.

# Precompile additional assets
Rails.application.config.assets.precompile += %w( admin_layout.css sales_index.css users_index.css admin_index.css custom_modal.css custom_modal.js )
