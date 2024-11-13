# frozen_string_literal: true

require "rails_helper"

describe "/users", type: :request do
  describe "POST" do
    subject { post "/api/v1/users", params: body, as: :json }

    let(:body) do
      {
        user: {
          email: "pablobello@hey.com",
          username: "pablobello",
          password: "123456",
          password_confirmation: "123456"
        }
      }
    end

    it { is_expected.to conform_schema(201) }

    context "with invalid data" do
      let(:body) do
        {
          user: {
            email: "invalid-email",
            username: "",
            password: "123",
            password_confirmation: "456"
          }
        }
      end

      it { is_expected.to conform_schema(422) }
    end

    context "with missing 'user' key" do
      let(:body) do
        {
          email: "pablobello@hey.com",
          username: "pablobello",
          password: "123456",
          password_confirmation: "123456"
        }
      end

      it { is_expected.to conform_schema(400) }
    end
  end
end
