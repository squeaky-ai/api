# frozen_string_literal: true

module Exceptions
  class RecordingNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.recording_not_found'))
      super
    end
  end
end
