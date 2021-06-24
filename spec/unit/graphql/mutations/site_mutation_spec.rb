# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::SiteMutation do
  describe '#ready?' do
    context 'when the user does not exist in the context' do
      subject do
        context = { current_user: nil }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an Unauthorized error' do
        expect { subject.ready?({}) }.to raise_error(Errors::Unauthorized)
      end
    end

    context 'when the user exists but the site does not' do
      let(:user) { create_user }

      subject do
        context = { current_user: user }
        described_class.new(object: {}, context: context, field: '')
      end

      it 'raises an SiteNotFound error' do
        expect { subject.ready?({}) }.to raise_error(Errors::SiteNotFound)
      end
    end

    context 'when the user exists and so does the site' do
      context 'and the user is a member' do
        let(:user) { create_user }
        let(:site) { create_site_and_team(user: create_user) }

        before { create_team(user: user, site: site, role: Team::MEMBER) }

        subject do
          context = { current_user: user }
          described_class.new(object: {}, context: context, field: '')
        end

        it 'raises an SiteForbidden error' do
          expect { subject.ready?({ site_id: site.id }) }.to raise_error(Errors::SiteForbidden)
        end
      end

      context 'and the user is an admin' do
        let(:user) { create_user }
        let(:site) { create_site_and_team(user: create_user) }

        before { create_team(user: user, site: site, role: Team::ADMIN) }

        subject do
          context = { current_user: user }
          described_class.new(object: {}, context: context, field: '')
        end

        it 'sets the user and the site as instance variables' do
          response = subject.ready?({ site_id: site.id })

          expect(response).to be true
          expect(subject.instance_variable_get(:@user)).to eq user
          expect(subject.instance_variable_get(:@site)).to eq site
        end
      end

      context 'and the user is the owner' do
        let(:user) { create_user }
        let(:site) { create_site_and_team(user: user, role: Team::OWNER) }

        subject do
          context = { current_user: user }
          described_class.new(object: {}, context: context, field: '')
        end

        it 'sets the user and the site as instance variables' do
          response = subject.ready?({ site_id: site.id })

          expect(response).to be true
          expect(subject.instance_variable_get(:@user)).to eq user
          expect(subject.instance_variable_get(:@site)).to eq site
        end
      end
    end
  end
end
