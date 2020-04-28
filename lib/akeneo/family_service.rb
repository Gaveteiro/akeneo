# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class FamilyService < ServiceBase
    def all
      Enumerator.new do |families|
        request_url = "/families?#{limit_param}"

        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |family| families << family }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end

    def find(code)
      response = get_request("/families/#{code}")

      response.parsed_response if response.success?
    end

    def variant(code, variant_code)
      response = get_request("/families/#{code}/variants/#{variant_code}")

      response.parsed_response if response.success?
    end

    def create_or_update_variant(family, code, options)
      patch_request("/families/#{family}/variants/#{code}", body: options.to_json)
    end
  end
end
