# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Webhooks::StripeController, type: :controller do
  describe 'POST /' do
    context 'when the event type is "checkout.session.completed"' do
      let(:customer) { create(:customer) }

      let(:stripe_event) do
        double(
          :strip_event, 
          type: 'checkout.session.completed',
          data: {
            'customer' => customer.customer_id
          }
        )
      end

      subject { get :index, body: '{}', as: :json }

      before do
        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
      end

      it 'returns the success message' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end

      it 'sets the customers status to be open' do
       expect { subject }.to change { customer.reload.status }.from('new').to('open')
      end
    end
  end

  context 'when the event type is "invoice.paid"' do
    let(:customer) { create(:customer) }

    let(:stripe_event) do
      double(
        :strip_event, 
        type: 'invoice.paid',
        data: {
          'customer' => customer.customer_id
        }
      )
    end

    subject { get :index, body: '{}', as: :json }

    before do
      allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
    end

    it 'returns the success message' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response.body).to eq({ success: true }.to_json)
    end

    it 'sets the customers status to be valid' do
     expect { subject }.to change { customer.reload.status }.from('new').to('valid')
    end
  end

  context 'when the event type is "invoice.payment_failed"' do
    let(:customer) { create(:customer) }

    let(:stripe_event) do
      double(
        :strip_event, 
        type: 'invoice.payment_failed',
        data: {
          'customer' => customer.customer_id
        }
      )
    end

    subject { get :index, body: '{}', as: :json }

    before do
      allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)
    end

    it 'returns the success message' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response.body).to eq({ success: true }.to_json)
    end

    it 'sets the customers status to be invalid' do
     expect { subject }.to change { customer.reload.status }.from('new').to('invalid')
    end
  end
end
