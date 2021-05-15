# frozen_string_literal: true

require 'aws-record'

# This is the table that the gateway uses to check whether or
# not the site is able to accept events. It is only used by the
# gateway, but needs to be created here
class Authorizer
  include Aws::Record

  set_table_name 'Authorizer'

  string_attr :site_id, hash_key: true
  string_attr :origin
  boolean_attr :active
  string_attr :created_at
  string_attr :updated_at
end
