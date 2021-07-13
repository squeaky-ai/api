# frozen_string_literal: true

module Errors
  # Raise when the user tries to modify parts of the
  # recording and they provide an invalid id
  class RecordingNotFound < GraphQL::ExecutionError
    def initialize(msg = I18n.t('site.validation.recording_not_found'))
      super
    end
  end
end
