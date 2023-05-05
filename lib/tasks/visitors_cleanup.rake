# frozen_string_literal: true

task visitors_cleanup: :environment do
  Visitor.find_each do |visitor|
    count = Recording.where(visitor_id: visitor.id).count
    visitor.destroy if count.zero?
  end
end
