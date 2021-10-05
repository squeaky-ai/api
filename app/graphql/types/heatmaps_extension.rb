# frozen_string_literal: true

module Types
  # Return the data requied for heatmaps
  class HeatmapsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:device, HeatmapsDeviceType, required: true, default_value: 'Desktop', description: 'The type of device to show')
      field.argument(:type, HeatmapsTypeType, required: true, default_value: 'Click', description: 'The type of heatmap to show')
      field.argument(:page, String, required: true, description: 'The page to show results for')
    end

    def resolve(object:, arguments:, **_rest)
      device_counts = devices(object.object[:id])

      puts '@@', arguments

      {
        **device_counts
      }
    end

    private

    def devices(site_id)
      results = Site
                .find(site_id)
                .recordings
                .select(:useragent)
                .uniq

      groups = results.partition { |r| UserAgent.parse(r.useragent).mobile? }

      {
        mobile_count: groups[0].size,
        desktop_count: groups[1].size
      }
    end
  end
end
