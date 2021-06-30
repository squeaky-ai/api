# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

search_mock = {
  'hits' => {
    'hits' => [],
    'total' => { 'value' => 0 }
  }
}

RSpec.describe Types::RecordingsExtension do
  describe '#resolve' do
    context 'when providing pagination' do
      let(:uuid) { SecureRandom.uuid }
      let(:page) { 0 }
      let(:size) { 15 }
      let(:query) { '' }

      let(:field) { double('field', argument: {}) }
      let(:object) { double('object', object: double('object', uuid: uuid)) }

      subject do
        arguments = { page: page, size: size, query: query, sort: 'DESC' }
        described_class.new(field: field, options: nil).resolve(object: object, arguments: arguments)
      end

      before do
        allow(SearchClient).to receive(:search).and_return(search_mock)
      end

      it 'calls the SearchClient with the pagination' do
        subject
        expect(SearchClient).to have_received(:search).with(
          index: Recording::INDEX,
          body: {
            from: page * size,
            size: size,
            sort: {
              timestamp: {
                order: 'desc',
                unmapped_type: 'date_nanos'
              }
            },
            query: {
              bool: {
                must: [
                  { term: { 'site_id.keyword': uuid } }
                ]
              }
            }
          }
        )
      end
    end

    describe 'when providing a search term' do
      let(:uuid) { SecureRandom.uuid }
      let(:page) { 0 }
      let(:size) { 15 }
      let(:query) { Faker::String.random }

      let(:field) { double('field', argument: {}) }
      let(:object) { double('object', object: double('object', uuid: uuid)) }

      subject do
        arguments = { page: page, size: size, query: query, sort: 'DESC' }
        described_class.new(field: field, options: nil).resolve(object: object, arguments: arguments)
      end

      before do
        allow(SearchClient).to receive(:search).and_return(search_mock)
      end

      it 'calls the SearchClient with the pagination' do
        subject
        expect(SearchClient).to have_received(:search).with(
          index: Recording::INDEX,
          body: {
            from: page * size,
            size: size,
            sort: {
              timestamp: {
                order: 'desc',
                unmapped_type: 'date_nanos'
              }
            },
            query: {
              bool: {
                must: [
                  { term: { 'site_id.keyword': uuid } }
                ],
                filter: [
                  { query_string: { query: "*#{query}*" } }
                ]
              }
            }
          }
        )
      end
    end
  end
end
