# typed: false
# frozen_string_literal: true

class DataExport < ApplicationRecord
  belongs_to :site

  after_destroy :remove_file!

  VISITORS = 0
  RECORDINGS = 1

  def self.name_for_type(type)
    case type
    when VISITORS
      'visitors'
    when RECORDINGS
      'recordings'
    end
  end

  private

  def remove_file!
    DataExportService.delete(data_export: self)
  end
end
