# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Webhooks::StripeController, type: :controller do
  describe 'POST /' do
    context 'when the event type is "checkout.session.completed"' do
      let(:billing) { create(:billing) }
      let(:payment_id) { SecureRandom.base36 }

      let(:stripe_event) do
        double(
          :stripe_event, 
          type: 'checkout.session.completed',
          data: double(:data, object: { 'customer' => billing.customer_id })
        )
      end

      let(:payment_methods_response) do
        double(:payment_methods_response, data: {
          'card' => {
            'brand' => 'visa',
            'country' => 'UK',
            'exp_month' => 1,
            'exp_year' => 3000,
            'last4' => '0000'
          },
          'billing_details' => {
            'name' => 'Bob Dylan',
            'email' => 'bigbob2022@gmail.com',
            'address' => {
              'line1' => 'Hollywood',
              'country' => 'US'
            }
          }
        })
      end

      subject { get :index, body: '{}', as: :json }

      before do
        allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)

        allow(Stripe::Customer).to receive(:retrieve)
          .with(billing.customer_id)
          .and_return('object' => { 'invoice_settings' => { 'default_payment_method' => payment_id } })

        allow(Stripe::PaymentMethod).to receive(:retrieve)
          .with(payment_id)
          .and_return(payment_methods_response)
      end

      it 'returns the success message' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ success: true }.to_json)
      end

      it 'sets the billing status to be open' do
       expect { subject }.to change { billing.reload.status }.from('new').to('open')
      end

      it 'sets the billing information' do
        subject
        billing.reload

        expect(billing.card_type).to eq 'visa'
        expect(billing.country).to eq 'UK'
        expect(billing.expiry).to eq '1/3000'
        expect(billing.card_number).to eq '0000'
        expect(billing.billing_name).to eq 'Bob Dylan'
        expect(billing.billing_email).to eq 'bigbob2022@gmail.com'
      end

      context 'when there are locked recordings' do
        before do
          create(:recording, site: billing.site, status: Recording::LOCKED)
          create(:recording, site: billing.site, status: Recording::LOCKED)
          create(:recording, site: billing.site, status: Recording::LOCKED)
        end
  
        it 'unlocks them' do
          expect { subject }.to change { billing.site.recordings.reload.where(status: Recording::LOCKED).size }.from(3).to(0)
        end
      end
    end

    context 'when the event type is "invoice.paid"' do
      let(:billing) { create(:billing) }
  
      let(:stripe_event) do
        double(
          :stripe_event, 
          type: 'invoice.paid',
          data: double(:data, object: { 
            'customer' => billing.customer_id,
            'hosted_invoice_url' => 'http://stripe.com/web',
            'invoice_pdf' => 'http://stripe.com/pdf',
            'lines' => {
              'data' => [
                {
                  'amount' => 1000,
                  'currency' => 'usd',
                  'period' => {
                    'start' => 1644052149,
                    'end' => 1646471349
                  },
                  'plan' => {
                    'id' => 'price_1KPOV6LJ9zG7aLW8tDzfMy0D',
                    'interval' => 'month'
                  }
                }
              ]
            }
          })
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
  
      it 'sets the billing status to be valid' do
       expect { subject }.to change { billing.reload.status }.from('new').to('valid')
      end
  
      it 'stores the invoice' do
        expect { subject }.to change { billing.reload.transactions.size }.from(0).to(1)
      end

      it 'sets the sites plan to the one from the billing' do
        expect { subject }.to change { billing.site.reload.plan }.from(0).to(1)
      end
    end
  
    context 'when the event type is "invoice.payment_failed"' do
      let(:billing) { create(:billing) }
  
      let(:stripe_event) do
        double(
          :stripe_event, 
          type: 'invoice.payment_failed',
          data: double(:data, object: { 'customer' => billing.customer_id })
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
  
      it 'sets the billing status to be invalid' do
       expect { subject }.to change { billing.reload.status }.from('new').to('invalid')
      end
    end
  end

  context 'when the event type is "customer.updated"' do
    let(:billing) { create(:billing) }
    let(:payment_id) { SecureRandom.base36 }

    let(:stripe_event) do
      double(
        :stripe_event, 
        type: 'customer.updated',
        data: double(:data, object: { 'id' => billing.customer_id })
      )
    end

    let(:payment_methods_response) do
      double(:payment_methods_response, data: {
        'card' => {
          'brand' => 'visa',
          'country' => 'UK',
          'exp_month' => 1,
          'exp_year' => 3000,
          'last4' => '0000'
        },
        'billing_details' => {
          'name' => 'Bob Dylan',
          'email' => 'bigbob2022@gmail.com',
          'address' => {
            'line1' => 'Hollywood',
            'country' => 'US'
          }
        }
      })
    end

    subject { get :index, body: '{}', as: :json }

    before do
      allow(Stripe::Event).to receive(:construct_from).and_return(stripe_event)

      allow(Stripe::Customer).to receive(:retrieve)
        .with(billing.customer_id)
        .and_return('object' => { 'invoice_settings' => { 'default_payment_method' => payment_id } })

      allow(Stripe::PaymentMethod).to receive(:retrieve)
        .with(payment_id)
        .and_return(payment_methods_response)
    end

    it 'returns the success message' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response.body).to eq({ success: true }.to_json)
    end

    it 'updates the billing' do
      subject
      billing.reload
      expect(billing.card_type).to eq 'visa'
    end
  end
end
