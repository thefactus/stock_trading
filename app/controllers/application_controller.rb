# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  attr_reader :current_user

  private

  # Override Devise's authentication method for Basic Auth
  def authenticate_user!
    authenticate_or_request_with_http_basic do |email, password|
      user = User.find_by(email: email)
      if user&.valid_password?(password)
        sign_in user, store: false
        @current_user = user # Manually set @current_user for this request
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end
  end

  def user_not_authorized
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end
end
