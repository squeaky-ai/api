# frozen_string_literal: true

module DudaService
  class Uninstall
    def initialize(site_name:)
      @site_name = site_name
    end

    def uninstall!
      site = ::Site.find_by!(uuid: site_name)
      return unless site

      site.team.each do |team|
        # Only delete the duda user if they have no
        # other sites. It could be that someone is
        # a member of another site and we don't want
        # to delete their user account
        team.user.destroy! if team.user.sites.size == 1
      end

      AdminMailer.site_destroyed(site).deliver_now
      site.destroy_all_recordings!
      site.destroy!
    end

    private

    attr_reader :site_name
  end
end
