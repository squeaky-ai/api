# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `AdminMailer`.
# Please instead update this file by running `bin/tapioca dsl AdminMailer`.

class AdminMailer
  class << self
    sig { params(site: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def site_destroyed(site); end

    sig { params(path: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def squeaky_url(path = T.unsafe(nil)); end
  end
end
