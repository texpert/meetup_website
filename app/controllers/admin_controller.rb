# frozen_string_literal: true

class AdminController < ApplicationController
  layout 'admin'

  # render admin dashboard
  def index
    render 'dashboard'
  end
end
