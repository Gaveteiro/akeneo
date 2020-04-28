# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class AuthorizationService < ServiceBase
    REFRESH_RATE_IN_SECONDS = 2000

    attr_accessor :access_token, :refresh_token, :last_refresh

    def initialize(url:)
      @url = url
    end

    def authorize!(client_id:, secret:, username:, password:)
      @client_id = client_id
      @secret = secret
      options = {
        body: authorization_body(username, password),
        headers: json_headers.merge(basic_authorization_header)
      }
      response = HTTParty.post("#{@url}/api/oauth/v1/token", options)
      store_tokens!(response)
      response
    end

    def fresh_access_token
      refresh!
      @access_token
    end

    private

    def refresh!
      return unless refresh_necessary?

      options = {
        body: refresh_body(@refresh_token),
        headers: json_headers.merge(basic_authorization_header),
        read_timeout: 300
      }
      response = HTTParty.post("#{@url}/api/oauth/v1/token", options)
      store_tokens!(response)
      @last_refresh = Time.now
      SemanticLogger['AuthorizationService.refresh!'].warn(payload: 'akeneo token refresh')
    end

    def refresh_necessary?
      (Time.now.to_i - @last_refresh.to_i) > REFRESH_RATE_IN_SECONDS
    end

    def store_tokens!(response)
      raise response.to_hash['message'] unless response.ok?

      @access_token = response['access_token']
      @refresh_token = response['refresh_token']
    end

    def basic_authorization_header
      auth_hash = Base64.strict_encode64("#{@client_id}:#{@secret}")

      { 'Authorization' => "Basic #{auth_hash}" }
    end

    def authorization_body(username, password)
      {
        username: username,
        password: password,
        grant_type: 'password'
      }.to_json
    end

    def refresh_body(refresh_token)
      {
        refresh_token: refresh_token,
        grant_type: 'refresh_token'
      }.to_json
    end
  end
end
