# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :add_logidze_meta, only: %i[create update] # rubocop:disable Rails/LexicallyScopedActionFilter

  def add_logidze_meta(&)
    Logidze.with_meta({ ip: request.ip, responsible: current_user&.id }, &)
  end
end
