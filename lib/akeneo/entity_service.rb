# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class EntityService < ServiceBase
    def initialize(url:, access_token:)
      @url = url
      @access_token = access_token
    end

    def create_several_entity_records(entity_name, entity_records)
      patch_request("/reference-entities/#{entity_name}/records", body: entity_records)
    end

    def find(entity_code, record_code)
      response = get_request("/reference-entities/#{entity_code}/records/#{record_code}")

      response.parsed_response if response.success?
    end
  end
end
