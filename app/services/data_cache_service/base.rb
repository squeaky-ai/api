# frozen_string_literal: true

module DataCacheService
  class Base
    def initialize(site:, user: nil, from_date: nil, to_date: nil, expires_in: 15.minutes)
      @site = site
      @user = user
      @expires_in = expires_in
      @from_date = from_date
      @to_date = to_date
    end

    def delete
      Rails.cache.delete(cache_key)
    end

    protected

    attr_reader :site, :user, :expires_in, :from_date, :to_date

    def cache(&block)
      block.call unless site
      Rails.cache.fetch(cache_key, expires_in:, &block)
    end

    private

    def cache_key
      key = "data_cache::#{self.class}::#{site.uuid}"
      key += "::#{user.id}" if user
      key += "::from_#{from_date}" if from_date
      key += "::to_#{to_date}" if to_date
      key
    end
  end
end
