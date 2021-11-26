# frozen_string_literal: true

require 'rails_helper'

feedback_create_mutation = <<-GRAPHQL
  mutation($input: FeedbackCreateInput!) {
    feedbackCreate(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::Create, type: :request do
  let(:user) { create_user }
  let(:type) { 'bug' }
  let(:title) { 'Hello!' }
  let(:message) { 'Hello again!' }

  before do
    stub = double
    allow(stub).to receive(:deliver_now)
    allow(FeedbackMailer).to receive(:feedback).and_return(stub)
  end

  subject do
    payload = { input: { type: type, subject: title, message: message } }
    graphql_request(feedback_create_mutation, payload, user)
  end

  it 'returns a generic message' do
    expect(subject['data']['feedbackCreate']).to eq('message' => 'Sent!')
  end

  it 'sends an email' do
    subject
    expect(FeedbackMailer).to have_received(:feedback).with(user, type, title, message)
  end
end
