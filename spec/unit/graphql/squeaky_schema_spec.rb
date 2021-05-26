# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SqueakySchema do
  describe '.resolve_type' do
    it 'raises an error because we should handle it at the type level' do
      expect { described_class.resolve_type(nil, nil, nil) }.to raise_error GraphQL::RequiredImplementationMissingError
    end
  end
end
