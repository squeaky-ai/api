# frozen_string_literal: true

require 'rails_helper'

data_export_create_mutation = <<-GRAPHQL
  mutation($input: DataExportCreateInput!) {
    dataExportCreate(input: $input) {
      filename
      exportType
      exportedAt
      startDate
      endDate
    }
  }
GRAPHQL

RSpec.describe Mutations::Exports::DataExportCreate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  let(:now) { Time.new(2023, 3, 16, 12, 0, 0) }

  before do
    allow(Time).to receive(:now).and_return(now)
    allow(DataExportJob).to receive(:perform_later)
  end

  subject do
    variables = {
      input: {
        siteId: site.id, 
        exportType: DataExport::RECORDINGS,
        startDate: '2023-03-09',
        endDate: '2023-03-16'
      }
    }
    graphql_request(data_export_create_mutation, variables, user)
  end

  it 'creates the capture' do
    expect { subject }.to change { site.reload.data_exports.size }.from(0).to(1)
  end

  it 'creates the correct filename' do
    subject
    data_export = site.data_exports.last
    expect(data_export.filename).to eq('recordings-1678968000.csv')
  end

  it 'kicks off the job to export the data' do
    subject
    expect(DataExportJob).to have_received(:perform_later)
  end
end
