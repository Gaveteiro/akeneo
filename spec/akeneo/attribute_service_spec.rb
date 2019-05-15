# frozen_string_literal: true

require 'akeneo/attribute_service'

describe Akeneo::AttributeService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#all' do
    let(:request_url) { 'http://akeneo.api/api/rest/v1/attributes' }
    let(:response_body) do
      {
        '_embedded' => {
          'items' => []
        }
      }.to_json
    end
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes all attributes request' do
      attributes = service.all

      attributes.each(&:inspect)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/attributes'
      )
    end

    it 'it returns the response body with items key' do
      response = service.all

      expect(response).to be_a(Enumerator)
    end
  end

  describe '#find' do
    let(:attribute_code) { 'an_attribute_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/attributes/#{attribute_code}" }
    let(:response_body) { { 'code' => attribute_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the attribute request' do
      service.find(attribute_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/attributes/an_attribute_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(attribute_code)

      expect(response).to eq('code' => 'an_attribute_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(attribute_code)

        expect(response).to be(nil)
      end
    end
  end
end
