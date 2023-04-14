# typed: false
# frozen_string_literal: true

class DataExportsController < ApplicationController
  before_action :authenticate_user!

  def show
    data_export = DataExport.find_by(
      id: data_export_params[:id],
      site_id: data_export_params[:site_id]
    )
    return not_found unless data_export

    fetch_file(data_export)
  end

  private

  def data_export_params
    params.permit(:id, :site_id)
  end

  def fetch_file(data_export)
    body = DataExportService.get(data_export:)

    return not_found unless body

    send_data(body, filename: data_export.filename, type: 'text/csv')
  end
end
