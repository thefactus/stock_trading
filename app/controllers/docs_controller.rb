# frozen_string_literal: true

class DocsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show; end

  def openapi
    file_path = Rails.root.join("docs/openapi.yml")
    if File.exist?(file_path)
      send_file file_path, type: "application/yaml", disposition: "inline"
    else
      render plain: "OpenAPI specification not found.", status: :not_found
    end
  end
end
