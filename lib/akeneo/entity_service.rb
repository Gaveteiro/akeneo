# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class EntityService < ServiceBase
    def initialize(url:, access_token:)
      @url = url
      @access_token = access_token
    end
    
    def create_or_update(entity_name, entity_code, entity_record)
      patch_request("/reference-entities/#{entity_name}/records/#{entity_code}", body: entity_record)
    end

    def create_several_entity_records(entity_name, entity_records)
      patch_request("/reference-entities/#{entity_name}/records", body: entity_records)
    end

    def find(entity_code, record_code)
      response = get_request("/reference-entities/#{entity_code}/records/#{record_code}")

      response.parsed_response if response.success?
    end

    def last_updated_in(entity_code, updated_time)
      hash = {}
      hash["updated"] = [{ operator: '>', value: updated_time.strftime('%FT%TZ') }]
      
      Enumerator.new do |entities|
        path = "/reference-entities/#{entity_code}/records"
        request_url = path + "?search=#{hash.to_json}"
        
        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |entity| entities << entity }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end

    def all(entity_code)
      Enumerator.new do |entities|
        request_url = "/reference-entities/#{entity_code}/records"

        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |entity| entities << entity }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end
  end
end
