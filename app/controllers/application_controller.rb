class ApplicationController < ActionController::Base
  around_action :add_logidze_meta, only: %i[create update]

  def add_logidze_meta(&block)
    Logidze.with_meta({ ip: request.ip, responsible: current_user&.id }, &block)
  end
end
