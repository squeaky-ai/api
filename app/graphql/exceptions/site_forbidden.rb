# typed: false
# frozen_string_literal: true

module Exceptions
  class SiteForbidden < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.forbidden'))
      super
    end
  end
end
