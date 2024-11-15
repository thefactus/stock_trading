# frozen_string_literal: true

module AuthenticationHelpers
  def basic_auth_headers(username, password)
    {
      "Authorization" => "Basic #{Base64.strict_encode64("#{username}:#{password}")}"
    }
  end
end
