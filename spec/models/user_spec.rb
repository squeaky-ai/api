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
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      let(:instance) { described_class.new(first_name: first_name, last_name: last_name) }

      it 'returns the full name' do
        expect(instance.full_name).to eq("#{first_name} #{last_name}")
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
      let(:instance) { described_class.create(email: Faker::Internet.email) }

      let(:site) do
        site = Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
        Team.create(role: 0, user: instance, site: site)
        site
      end

      it 'returns false' do
        expect(instance.admin_for?(site)).to be false
      end
    end

    context 'when the user is an admin' do
      let(:instance) { described_class.create(email: Faker::Internet.email) }

      let(:site) do
        site = Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
        Team.create(role: 1, user: instance, site: site)
        site
      end

      it 'returns true' do
        expect(instance.admin_for?(site)).to be true
      end
    end

    context 'when the user is the owner' do
      let(:instance) { described_class.create(email: Faker::Internet.email) }

      let(:site) do
        site = Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
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
      let(:instance) { described_class.create(email: Faker::Internet.email) }

      let(:site) do
        Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
      end

      it 'returns false' do
        expect(instance.member_of?(site)).to be false
      end
    end

    context 'when the user is a member of the team' do
      let(:instance) { described_class.create(email: Faker::Internet.email) }

      let(:site) do
        site = Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
        Team.create(role: 2, user: instance, site: site)
        site
      end

      it 'returns true' do
        expect(instance.member_of?(site)).to be true
      end
    end
  end
end
