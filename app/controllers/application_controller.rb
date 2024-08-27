# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :add_logidze_meta, only: %i[create update] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :turbo_frame_request_variant

  def add_logidze_meta(&)
    Logidze.with_meta({ ip: request.ip, responsible: current_user&.id }, &)
  end

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
