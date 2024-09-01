# frozen_string_literal: true

# Allow processing of all the scss files from app/assets/stylesheets - by default `dartsass-rails` is processing only
# the `application.scss` file
Rails.application.config.dartsass.builds = {
  '.' => '.'
}
