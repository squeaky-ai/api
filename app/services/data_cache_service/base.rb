# frozen_string_literal: true

module DataCacheService
  class Base
    def initialize(site_id:, expires_in: 15.minutes, **kwargs)
      @site_id = site_id
      @expires_in = expires_in
      @args = kwargs
    end

    protected

    attr_reader :site_id, :expires_in, :args

    def cache(&)
      Rails.cache.fetch(cache_key, expires_in:, &)
    end

    private

    def cache_key
      "data_cache::#{self.class}::#{site_id}"
    end
  end
end
