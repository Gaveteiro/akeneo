# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class MeasureFamilyService < ServiceBase
    def all
      Enumerator.new do |measures|
        request_url = "/measure-families?#{limit_param}"

        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |measure| measures << measure }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end

    def find(code)
      response = get_request("/measure-families/#{code}")

      response.parsed_response if response.success?
    end
  end
end
