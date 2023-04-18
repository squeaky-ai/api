# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paths do
  describe '.replace_route_with_wildcard' do
    [
      {
        in: '/',
        out: '/'
      },
      {
        in: '/foo',
        out: '/foo'
      },
      {
        in: '/foo/bar',
        out: '/foo/bar'
      },
      {
        in: '/foo/:bar',
        out: '/foo/%'
      },
      {
        in: '/foo/:bar/baz',
        out: '/foo/%/baz'
      },
      {
        in: '/foo/:bar/baz/:what_comes_after_those',
        out: '/foo/%/baz/%'
      }
    ].each do |scenario|
      context "when the input is: #{scenario[:in]}" do
        it "returns: #{scenario[:out]}" do
          out = described_class.replace_route_with_wildcard(scenario[:in])
          expect(out).to eq(scenario[:out])
        end
      end
    end
  end

  describe '.format_path_with_routes' do
    let(:path) { '/foo/bar' }

    subject { described_class.format_path_with_routes(path, routes) }

    context 'when there are no routes' do
      let(:routes) { [] }

      it 'returns the expected path' do
        expect(subject).to eq('/foo/bar')
      end
    end

    context 'when there are routes but none match' do
      let(:routes) { ['/teapot/:teabag'] }

      it 'returns the expected path' do
        expect(subject).to eq('/foo/bar')
      end
    end

    context 'when there are routes and they match' do
      let(:routes) { ['/foo/:foo'] }

      it 'returns the expected path' do
        expect(subject).to eq('/foo/:foo')
      end
    end
  end

  describe '.format_pages_with_routes' do
    let(:pages) do
      [
        {
          'url' => '/',
          'count' => 5
        },
        {
          'url' => '/foo',
          'count' => 2
        },
        {
          'url' => '/bar',
          'count' => 2
        },
        {
          'url' => '/foo/bar',
          'count' => 6
        },
        {
          'url' => '/foo/baz',
          'count' => 2
        }
      ]
    end

    subject { described_class.format_pages_with_routes(pages, routes) }

    context 'when there are no routes' do
      let(:routes) { [] }

      it 'returns the expected pages' do
        expect(subject).to eq(
          [
            {
              'url' => '/',
              'count' => 5
            },
            {
              'url' => '/foo',
              'count' => 2
            },
            {
              'url' => '/bar',
              'count' => 2
            },
            {
              'url' => '/foo/bar',
              'count' => 6
            },
            {
              'url' => '/foo/baz',
              'count' => 2
            }
          ]
        )
      end
    end

    context 'when there are routes but none match' do
      let(:routes) { ['/teapot/:teabag'] }

      it 'returns the expected pages' do
        expect(subject).to eq(
          [
            {
              'url' => '/',
              'count' => 5
            },
            {
              'url' => '/foo',
              'count' => 2
            },
            {
              'url' => '/bar',
              'count' => 2
            },
            {
              'url' => '/foo/bar',
              'count' => 6
            },
            {
              'url' => '/foo/baz',
              'count' => 2
            }
          ]
        )
      end
    end

    context 'when there are routes and they match' do
      let(:routes) { ['/foo/:foo'] }

      it 'returns the expected pages' do
        expect(subject).to eq(
          [
            {
              'url' => '/',
              'count' => 5
            },
            {
              'url' => '/foo',
              'count' => 2
            },
            {
              'url' => '/bar',
              'count' => 2
            },
            {
              'url' => '/foo/:foo',
              'count' => 8
            },
          ]
        )
      end
    end
  end
end
