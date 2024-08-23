# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    skip_before_action :require_no_authentication
    skip_before_action :assert_reset_token_passed, only: :edit # rubocop:disable Rails/LexicallyScopedActionFilter

    # GET /resource/password/new
    # def new
    #   super
    # end

    # POST /resource/password
    # def create
    #   super
    # end

    # GET /resource/password/edit?reset_password_token=abcdef

    # PUT /resource/password
    # def update
    #   super
    # end

    # protected

    # def after_resetting_password_path_for(resource)
    #   super(resource)
    # end

    # The path used after sending reset password instructions
    # def after_sending_reset_password_instructions_path_for(resource_name)
    #   super(resource_name)
    # end
  end
end
