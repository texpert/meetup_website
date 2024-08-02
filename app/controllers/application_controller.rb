class ApplicationController < ActionController::Base
  private

  def current_user
    rodauth.rails_account
  end
  helper_method :current_user

  def authenticate
    rodauth.require_account
  end
end
