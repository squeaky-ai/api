# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sites::HeatmapsController, type: :controller do
  describe 'GET /sites/heatmaps/cursors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:params) do
      { 
        site_id: site.id,
        device: 'Desktop',
        page_url: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30'
      }
    end

    subject do
      sign_in user
      get :cursors, params:
    end

    context 'when there is no data for this page' do
      it 'returns an empty array' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to eq([])
      end
    end

    context 'when there is data for this page' do
      before do
        ClickHouse::CursorEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            coordinates: [
              { absolute_x: 1353, absolute_y: 660 },
              { absolute_x: 1353, absolute_y: 661 },
              { absolute_x: 1353, absolute_y: 670 },
              { absolute_x: 1353, absolute_y: 675 },
              { absolute_x: 1353, absolute_y: 676 }
            ].to_json,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            timestamp: 1651153548001
          }
        end
      end

      it 'returns the data' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to match_array(
          [
            {
              'count' => 3, 
              'x' => 1360,
              'y' => 672
            },
            {
              'count' => 2, 
              'x' => 1360,
              'y' => 688
            }
          ]
        )
      end
    end
  end

  describe 'GET /sites/heatmaps/click_counts' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:params) do
      { 
        site_id: site.id,
        device: 'Desktop',
        page_url: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30'
      }
    end

    subject do
      sign_in user
      get :click_counts, params:
    end

    context 'when there is no data for this page' do
      it 'returns an empty array' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to eq([])
      end
    end
    
    context 'when there is data for this page' do
      before do
        ClickHouse::ClickEvent.insert do |buffer|
          5.times do |i|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: site.id,
              url: '/',
              selector: 'html > body',
              coordinates_x: 10,
              coordinates_y: 10,
              viewport_x: 1920,
              viewport_y: 1080,
              device_x: 1920,
              device_y: 1080,
              relative_to_element_x: 0,
              relative_to_element_y: 0,
              timestamp: 1651153548001
            }
          end

          3.times do |i|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: site.id,
              url: '/',
              selector: 'p#foo',
              coordinates_x: 10,
              coordinates_y: 10,
              viewport_x: 1920,
              viewport_y: 1080,
              device_x: 1920,
              device_y: 1080,
              relative_to_element_x: 0,
              relative_to_element_y: 0,
              timestamp: 1651153548001
            }
          end
        end
      end

      it 'returns the data' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to match_array(
          [
            {
              'count' => 5,
              'selector' => 'html > body'
            },
            {
              'count' => 3,
              'selector' => 'p#foo'
            }
          ]
        )
      end
    end
  end

  describe 'GET /sites/heatmaps/click_positions' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:params) do
      { 
        site_id: site.id,
        device: 'Desktop',
        page_url: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30'
      }
    end

    subject do
      sign_in user
      get :click_positions, params:
    end

    context 'when there is no data for this page' do
      it 'returns an empty array' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to eq([])
      end
    end

    context 'when there is data for this page' do
      before do
        ClickHouse::ClickEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            selector: 'html > body',
            coordinates_x: 10,
            coordinates_y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            relative_to_element_x: 10,
            relative_to_element_y: 10,
            timestamp: 1651153548001
          }
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            selector: 'p#foo',
            coordinates_x: 10,
            coordinates_y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            relative_to_element_x: 10,
            relative_to_element_y: 10,
            timestamp: 1651153548001
          }
        end
      end

      it 'returns the data' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to match_array(
          [
            {
              'selector' => 'html > body',
              'relative_to_element_x' => 10,
              'relative_to_element_y' => 10
            },
            {
              'selector' => 'p#foo',
              'relative_to_element_x' => 10,
              'relative_to_element_y' => 10
            }
          ]
        )
      end
    end
  end

  describe 'GET /sites/heatmaps/scrolls' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:params) do
      { 
        site_id: site.id,
        device: 'Desktop',
        page_url: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30'
      }
    end

    subject do
      sign_in user
      get :scrolls, params:
    end

    context 'when there is no data for this page' do
      it 'returns an empty array' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to eq([])
      end
    end

    context 'when there is data for this page' do
      before do
        ClickHouse::ScrollEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            x: 10,
            y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            timestamp: 1651153548001
          }
        end
      end

      it 'returns the data' do
        subject

        expect(response).to have_http_status(200)
        expect(json_body).to match_array(
          [
            {
              'y' => 10
            }
          ]
        )
      end
    end
  end
end
