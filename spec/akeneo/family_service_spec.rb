# frozen_string_literal: true

require 'akeneo/family_service'

describe Akeneo::FamilyService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#all' do
    let(:request_url) { 'http://akeneo.api/api/rest/v1/families?limit=100' }
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

    it 'makes all families request' do
      families = service.all

      families.each(&:inspect)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/families?limit=100'
      )
    end

    it 'it returns the response body with items key' do
      response = service.all

      expect(response).to be_a(Enumerator)
    end
  end

  describe '#find' do
    let(:family_code) { 'a_family_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/families/#{family_code}" }
    let(:response_body) { { 'code' => family_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the family request' do
      service.find(family_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/families/a_family_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(family_code)

      expect(response).to eq('code' => 'a_family_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(family_code)

        expect(response).to be(nil)
      end
    end
  end

  describe '#variant' do
    let(:family_code) { 'a_family_code' }
    let(:family_variant_code) { 'a_family_variant_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/families/#{family_code}/variants/#{family_variant_code}" }
    let(:response_body) { { 'code' => family_variant_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the family request' do
      service.variant(family_code, family_variant_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/families/a_family_code/variants/a_family_variant_code'
      )
    end

    it 'it returns the response body' do
      response = service.variant(family_code, family_variant_code)

      expect(response).to eq('code' => 'a_family_variant_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.variant(family_code, family_variant_code)

        expect(response).to be(nil)
      end
    end
  end
end
