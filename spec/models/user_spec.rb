# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#full_name' do
    context 'when the user has not filled out their name' do
      let(:instance) { described_class.new }

      it 'returns nil' do
        expect(instance.full_name).to be_nil
      end
    end

    context 'when the user has filled out their name' do
      let(:instance) { create_user }

      it 'returns the full name' do
        expect(instance.full_name).to eq "#{instance.first_name} #{instance.last_name}"
      end
    end
  end

  describe '#admin_for?' do
    context 'when the site nil' do
      let(:instance) { described_class.new }

      it 'returns false' do
        site = nil

        expect(instance.admin_for?(site)).to be false
      end
    end

    context 'when the user is a member' do
      let(:instance) { create_user }

      let(:site) do
        site = create_site
        Team.create(role: 0, user: instance, site: site)
        site
      end

      it 'returns false' do
        expect(instance.admin_for?(site)).to be false
      end
    end

    context 'when the user is an admin' do
      let(:instance) { create_user }

      let(:site) do
        site = create_site
        Team.create(role: 1, user: instance, site: site)
        site
      end

      it 'returns true' do
        expect(instance.admin_for?(site)).to be true
      end
    end

    context 'when the user is the owner' do
      let(:instance) { create_user }

      let(:site) do
        site = create_site
        Team.create(role: 2, user: instance, site: site)
        site
      end

      it 'returns true' do
        expect(instance.admin_for?(site)).to be true
      end
    end
  end

  describe '#member_of?' do
    context 'when the user is not a member of the team' do
      let(:instance) { create_user }

      let(:site) { create_site }

      it 'returns false' do
        expect(instance.member_of?(site)).to be false
      end
    end

    context 'when the user is a member of the team' do
      let(:instance) { create_user }

      let(:site) do
        site = create_site
        Team.create(role: 2, user: instance, site: site)
        site
      end

      it 'returns true' do
        expect(instance.member_of?(site)).to be true
      end
    end
  end
end
