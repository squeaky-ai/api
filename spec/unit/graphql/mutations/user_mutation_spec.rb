# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::UserMutation do
  describe '#ready?' do
    context 'when the user exists in the context' do
      let(:user) { double('user') }

      let(:instance) do
        context = { current_user: user }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'sets the user as an instance variable' do
        response = instance.ready?({})

        expect(response).to eq(true)
        expect(instance.instance_variable_get(:@user)).to eq(user)
      end
    end

    context 'when the user does not exist in the context' do
      let(:instance) do
        context = { current_user: nil }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an Unauthorized error' do
        expect { instance.ready?({}) }.to raise_error(Errors::Unauthorized)
      end
    end
  end
end
