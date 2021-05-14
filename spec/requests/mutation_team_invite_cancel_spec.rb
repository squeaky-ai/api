# # frozen_string_literal: true

# require 'rails_helper'

# team_invite_cancel_mutation = <<-GRAPHQL
#   mutation($site_id: ID!, $team_id: ID!) {
#     teamInviteResend(input: { siteId: $site_id, teamId: $team_id }) {
#       team {
#         id
#         role
#         status
#         user {
#           id
#           firstName
#           lastName
#           email
#         }
#       }
#     }
#   }
# GRAPHQL

# RSpec.describe 'Mutation team cancel resend', type: :request do

# end
