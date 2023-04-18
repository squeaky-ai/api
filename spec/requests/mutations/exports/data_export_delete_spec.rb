# frozen_string_literal: true

require 'rails_helper'

data_export_delete_mutation = <<-GRAPHQL
  mutation($input: DataExportDeleteInput!) {
    dataExportDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Exports::DataExportDelete, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  let!(:data_export) { create(:data_export, site:) }

  before do
    allow(DataExportService).to receive(:delete)
  end

  subject do
    variables = {
      input: {
        siteId: site.id, 
        dataExportId: data_export.id
      }
    }
    graphql_request(data_export_delete_mutation, variables, user)
  end

  it 'deletes the capture' do
    expect { subject }.to change { site.reload.data_exports.size }.from(1).to(0)
  end

  it 'deletes the S3 object' do
    subject
    expect(DataExportService).to have_received(:delete).with(data_export:)
  end
end
