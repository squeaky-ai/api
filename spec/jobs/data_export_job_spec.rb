# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataExportJob, type: :job do
  include ActiveJob::TestHelper

  before do
    allow(DataExportService).to receive(:create)
  end

  subject { described_class.perform_now(data_export.id) }

  context 'when it is a recording export' do
    let!(:data_export) { create(:data_export, export_type: DataExport::RECORDINGS, site:) }

    context 'and there is no data' do
      let(:site) { create(:site) }

      it 'uploads an empty string' do
        subject
        expect(DataExportService).to have_received(:create).with(body: '', data_export:)
      end

      it 'sets the exported_at timestamp' do
        expect { subject }.to change { data_export.reload.exported_at.nil? }.from(true).to(false)
      end
    end

    context 'and there is some data' do
      let(:site) { create(:site) }

      before do
        create(:recording, site:)
        create(:recording, site:)
      end

      it 'uploads an the CSV' do
        subject
        expect(DataExportService).to have_received(:create).with(body: anything, data_export: data_export.reload)
      end

      it 'sets the exported_at timestamp' do
        expect { subject }.to change { data_export.reload.exported_at.nil? }.from(true).to(false)
      end
    end
  end

  context 'when it is a visitors export' do
    let!(:data_export) { create(:data_export, export_type: DataExport::VISITORS, site:) }

    context 'and there is no data' do
      let(:site) { create(:site) }

      it 'uploads an empty string' do
        subject
        expect(DataExportService).to have_received(:create).with(body: '', data_export:)
      end

      it 'sets the exported_at timestamp' do
        expect { subject }.to change { data_export.reload.exported_at.nil? }.from(true).to(false)
      end
    end

    context 'and there is some data' do
      let(:site) { create(:site) }

      before do
        create(:visitor, site_id: site.id)
        create(:visitor, site_id: site.id)
      end

      it 'uploads an the CSV' do
        subject
        expect(DataExportService).to have_received(:create).with(body: anything, data_export: data_export.reload)
      end

      it 'sets the exported_at timestamp' do
        expect { subject }.to change { data_export.reload.exported_at.nil? }.from(true).to(false)
      end
    end
  end
end
