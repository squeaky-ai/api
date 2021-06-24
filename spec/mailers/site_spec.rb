# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteMailer, type: :mailer do
  describe 'destroyed' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: create_user) }
    let(:mail) { described_class.destroyed(user.email, site) }

    it 'renders the headers' do
      expect(mail.subject).to eq "The team account for #{site.name} has been deleted"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end
end
