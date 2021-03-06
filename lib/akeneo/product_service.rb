# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class ProductService < ServiceBase
    def initialize(url:, access_token:, product_model_service:, family_service:)
      @url = url
      @access_token = access_token
      @product_model_service = product_model_service
      @family_service = family_service
    end

    def find(id)
      response = get_request("/products/#{id}")

      response.parsed_response if response.success?
    end

    def find_by(custom_field, value)
      hash = {}
      hash[custom_field] = [{ operator: '=', value: value }]

      path = "/products?#{pagination_param}&#{limit_param}"
      path = path + "&search=#{hash.to_json}"

      response = get_request(path)
      extract_collection_items(response) #.each { |product| products << product }
    end

    def find_many(custom_field, values)
      hash = {}
      hash[custom_field] = [{ operator: 'IN', value: values }]

      path = "/products?#{pagination_param}&#{limit_param}"
      path = path + "&search=#{hash.to_json}"

      response = get_request(path)
      extract_collection_items(response)
    end

    def brothers_and_sisters(id)
      akeneo_product = find(id)
      akeneo_parent = load_akeneo_parent(akeneo_product['parent'])
      akeneo_grand_parent = load_akeneo_parent(akeneo_parent['parent']) unless akeneo_parent.nil?

      parents = load_parents(akeneo_product['family'], akeneo_parent, akeneo_grand_parent)

      load_products(akeneo_product, akeneo_product['family'], parents)
    end

    def all(with_family: nil, with_completeness: nil, updated_after: nil, with_categories: nil)
      Enumerator.new do |products|
        path = build_path(with_family, with_completeness, updated_after, with_categories)

        loop do
          response = get_request(path)
          extract_collection_items(response).each { |product| products << product }
          path = extract_next_page_path(response)
          break unless path
        end
      end
    end

    def where(attribute, condition, value, page=nil)
      query_string = {
        "#{attribute}": [{ operator: condition, value: value }],
        "atributo_situacao": [{"operator": "NOT IN", "value": ["5","7","8","9"]}],
        "atributo_altura_erp": [{"operator": "NOT EMPTY"}],
        "atributo_largura_erp": [{"operator": "NOT EMPTY"}],
        "atributo_comprimento_erp": [{"operator": "NOT EMPTY"}],
        "atributo_peso_bruto_erp": [{"operator": "NOT EMPTY"}],
        "atributo_peso_liquido_erp": [{"operator": "NOT EMPTY"}]
      }.to_json
      # path = "/products?search=#{query_string}"

      path = "/products?pagination_type=page&limit=20&with_count=true&search=#{query_string}"
      path += "&page=#{page}" if page.present?
      # Enumerator.new do |products|
      #   loop do
      #     response = get_request(path)
      #     extract_collection_items(response).each { |product| products << product }
      #     path = extract_next_page_path(response)
      #     break unless path
      #   end
      # end
      response = get_request(path)
      # total_items = response.parsed_response['items_count']

      extract_collection_items_with_count(response)
    end

    def create_or_update(code, options)
      patch_request("/products/#{code}", body: options.to_json)
    end

    def create_several(product_objects)
      patch_for_collection_request('/products', body: product_objects)
    end

    private

    def build_path(family, completeness, updated_after, with_categories)
      path = "/products?#{pagination_param}&#{limit_param}"
      path + search_params(
        family: family,
        completeness: completeness,
        updated_after: updated_after,
        with_categories: with_categories
      )
    end

    def load_akeneo_parent(code)
      return unless code

      @product_model_service.find(code)
    end

    def load_parents(family, akeneo_parent, akeneo_grand_parent)
      return [] if akeneo_parent.nil?
      return [akeneo_parent] if akeneo_grand_parent.nil?

      @product_model_service.all(with_family: family).select do |parent|
        parent['parent'] == akeneo_grand_parent['code']
      end
    end

    def load_products(akeneo_product, family, parents)
      return [akeneo_product] if parents.empty?

      products = all(with_family: family)
      parent_codes = parents.map { |parent| parent['code'] }

      products.select do |product|
        parent_codes.include?(product['parent'])
      end.flatten
    end

    def find_product_image_level(family, family_variant)
      family_variant = @family_service.variant(family, family_variant)

      product_image_attribute_set = family_variant['variant_attribute_sets'].find do |attribute_set|
        attribute_set['attributes'].include?('product_images')
      end

      return 0 unless product_image_attribute_set

      product_image_attribute_set.fetch('level', 0)
    end
  end
end
