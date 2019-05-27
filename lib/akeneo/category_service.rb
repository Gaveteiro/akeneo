# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class CategoryService < ServiceBase
    def all
      Enumerator.new do |categories|
        request_url = "/categories?#{limit_param}"

        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |category| categories << category }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end

    def find(code)
      response = get_request("/categories/#{code}")

      response.parsed_response if response.success?
    end
  end
end
