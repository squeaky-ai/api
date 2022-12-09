# frozen_string_literal: true

module DudaService
  class Uninstall
    def initialize(site_name:)
      @site_name = site_name
    end

    def uninstall!
      site = ::Site.find_by(uuid: site_name)
      site.destroy_all_recordings!
      site.destroy!
    end

    private

    attr_reader :site_name
  end
end
