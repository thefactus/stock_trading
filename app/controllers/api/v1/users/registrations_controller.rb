# frozen_string_literal: true

module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        skip_before_action :authenticate_user!, only: [:create]

        respond_to :json

        # Override the create action to prevent Devise from signing in the user
        def create
          build_resource(sign_up_params)

          if resource.save
            render json: { message: "Signed up successfully." }, status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:registration).require(:user).permit(:email, :password, :password_confirmation, :username)
        end

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { message: "User created successfully", user: resource }, status: :created
          else
            render json: { errors: resource.errors }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
