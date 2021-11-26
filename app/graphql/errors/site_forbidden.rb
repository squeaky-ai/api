# frozen_string_literal: true

module Errors
  class SiteForbidden < GraphQL::ExecutionError
    def initialize(msg = I18n.t('team.validation.forbidden'))
      super
    end
  end
end
