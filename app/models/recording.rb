# frozen_string_literal: true

# Whenever a user lands on the site we drop a session_id
# token in the session storage. Each of these sessions is
# stored in this table, a recording will have many events
class Recording < ApplicationRecord
  belongs_to :site

  def active
    false # TODO
  end

  def page_count
    page_views.uniq.size
  end

  def duration
    return 0 unless created_at && updated_at

    (updated_at - created_at).round
  end
end
