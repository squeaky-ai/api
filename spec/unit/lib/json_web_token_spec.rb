# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JsonWebToken do
  describe '.encode' do
    context 'when an expiry is given' do
      payload = { id: 1 }
      expiry = 1.year.from_now

      before do
        @token = JsonWebToken.encode(payload, expiry)
      end

      it 'retruns a jwt' do
        expect(@token).not_to be nil
      end

      it 'contains the user id and expiry' do
        contents = JsonWebToken.decode(@token)
        expect(contents[:id]).to eq payload[:id]
        expect(contents[:exp]).to eq expiry.to_i
      end
    end

    context 'when an expiry is not given' do
      payload = { id: 1 }

      before do
        @token = JsonWebToken.encode(payload)
      end

      it 'sets a default expiry of 1 month' do
        contents = JsonWebToken.decode(@token)
        expect(contents[:exp]).to eq 1.month.from_now.to_i
      end
    end
  end

  describe '.decode' do
    context 'when the token is valid' do
      payload = { id: 1 }
      token = JsonWebToken.encode(payload)

      it 'returns the id' do
        payload = JsonWebToken.decode(token)
        expect(payload[:id]).to eq payload[:id]
      end
    end

    context 'when the token has expired' do
      payload = { id: 1 }
      expiry = 1.month.ago
      token = JsonWebToken.encode(payload, expiry)

      it 'raises an error' do
        expect { JsonWebToken.decode(token) }.to raise_error(JWT::ExpiredSignature)
      end
    end

    context 'when the token is not a jwt' do
      token = 'sddfdfgdgfgdf1231231'

      it 'raises an error' do
        expect { JsonWebToken.decode(token) }.to raise_error(JWT::DecodeError)
      end
    end
  end
end
