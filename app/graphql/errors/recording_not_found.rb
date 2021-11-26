# frozen_string_literal: true

module Errors
  class RecordingNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.recording_not_found'))
      super
    end
  end
end
