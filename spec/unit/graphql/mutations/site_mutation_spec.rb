# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::SiteMutation do
  describe '#ready?' do
    context 'when the user does not exist in the context' do
      let(:instance) do
        context = { current_user: nil }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an Unauthorized error' do
        expect { instance.ready?({}) }.to raise_error(Errors::Unauthorized)
      end
    end

    context 'when the user exists but the site does not' do
      let(:user) { double('user', { sites: [] }) }

      let(:instance) do
        context = { current_user: user }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an SiteNotFound error' do
        expect { instance.ready?({}) }.to raise_error(Errors::SiteNotFound)
      end
    end

    context 'when the user exists and so does the site' do
      context 'and the user is not an admin' do
        let(:site) { double('site', id: 1) }
        let(:user) { double('user', sites: [site]) }

        let(:instance) do
          allow(user).to receive(:admin_for?).and_return(false)

          context = { current_user: user }
          described_class.new(object: {}, context: context, field: '')
        end

        it 'raises an SiteForbidden error' do
          expect { instance.ready?({ site_id: 1 }) }.to raise_error(Errors::SiteForbidden)
        end
      end

      context 'and the user is an admin' do
        let(:site) { double('site', id: 1) }
        let(:user) { double('user', { sites: [site] }) }

        let(:instance) do
          allow(user).to receive(:admin_for?).and_return(true)

          context = { current_user: user }
          described_class.new(object: {}, context: context, field: '')
        end

        it 'sets the user and the site as instance variables' do
          response = instance.ready?({ site_id: 1 })

          expect(response).to eq(true)
          expect(instance.instance_variable_get(:@user)).to eq(user)
          expect(instance.instance_variable_get(:@site)).to eq(site)
        end
      end
    end
  end
end
