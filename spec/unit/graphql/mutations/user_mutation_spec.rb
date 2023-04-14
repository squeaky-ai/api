# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UserMutation do
  describe '#ready?' do
    context 'when the user exists in the context' do
      let(:user) { double('user') }

      subject do
        context = { current_user: user }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'sets the user as an instance variable' do
        response = subject.ready?({})

        expect(response).to be true
        expect(subject.instance_variable_get(:@user)).to eq user
      end
    end

    context 'when the user does not exist in the context' do
      subject do
        context = { current_user: nil }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an Unauthorized error' do
        expect { subject.ready?({}) }.to raise_error(Exceptions::Unauthorized)
      end
    end
  end
end
