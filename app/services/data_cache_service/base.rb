# frozen_string_literal: true

module DataCacheService
  class Base
    def initialize(site_id:, from_date: nil, to_date: nil, expires_in: 15.minutes)
      @site_id = site_id
      @expires_in = expires_in
      @from_date = from_date
      @to_date = to_date
    end

    protected

    attr_reader :site_id, :expires_in, :from_date, :to_date

    def cache(&)
      Rails.cache.fetch(cache_key, expires_in:, &)
    end

    private

    def cache_key
      key = "data_cache::#{self.class}::#{site_id}"
      key += "::from_#{from_date}" if from_date
      key += "::to_#{to_date}" if to_date
      key
    end
  end
end
