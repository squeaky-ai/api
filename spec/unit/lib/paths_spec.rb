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
end
