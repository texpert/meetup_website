source 'https://rubygems.org'

ruby file: '.tool-versions'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'

gem 'bootsnap', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'dartsass-rails'
gem 'devise'
gem 'devise-multi_email'
gem 'discard'
gem 'fx' # Versioned database functions and triggers for Rails, used by logidze to work with db/schema.rb
gem 'importmap-rails' # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'logidze' # Database changes log for Rails
gem 'pg', '~> 1.5' # Use postgresql as the database for Active Record
gem 'propshaft'
gem 'puma', '>= 5.0' # Use the Puma web server [https://github.com/puma/puma]
gem 'solid_cache'
gem 'stimulus-rails' # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'turbo-rails' # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ]
end

group :development do
  gem 'foreman'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'web-console' # Use console on exceptions pages [https://github.com/rails/web-console]
end
