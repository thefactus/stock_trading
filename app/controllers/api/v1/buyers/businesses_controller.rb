# frozen_string_literal: true

module Api
  module V1
    module Buyers
      class BusinessesController < ApplicationController
        def index
          authorize Business, :index?

          @businesses = policy_scope(Business)
          render json: @businesses.as_json(only: %i[id name total_shares available_shares]), status: :ok
        end
      end
    end
  end
end
