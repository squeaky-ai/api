# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingsQuery do
  context 'when no filters or search is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {}
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a search is provided' do
    let(:site_id) { 'site_id' }
    let(:search) { 'hello' }

    let(:filters) do
      {}
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          filter: [
            {
              query_string: { query: "*#{search}*" }
            }
          ],
          must: [
            {
              term: { site_id: { value: site_id } }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a browser filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        browsers: ['Firefox']
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              terms: { 'device.browser_name.keyword'.to_sym => ['Firefox'] }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a device filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        devices: ['Mobile']
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              terms: { 'device.device_type.keyword'.to_sym => ['Mobile'] }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a language filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        languages: ['English']
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              terms: { 'language.keyword'.to_sym => ['English'] }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a start url filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        start_url: '/'
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              term: { 'start_page.keyword'.to_sym => '/' }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a exit url filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        exit_url: '/'
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              term: { 'exit_page.keyword'.to_sym => '/' }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a visited page filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        visited_pages: ['/']
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              terms: { 'page_views.keyword'.to_sym => ['/'] }
            }
          ],
          must_not: []
        }  
      )
    end
  end

  context 'when a unvisited page filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        unvisited_pages: ['/']
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            }
          ],
          must_not: [
            {
              terms: { 'page_views.keyword'.to_sym => ['/'] }
            }
          ]
        }  
      )
    end
  end

  context 'when a status filter is applied' do
    context 'and the status is new' do
      let(:site) { create_site }
      let(:search) { '' }

      let(:recording_ids) do
        recording_1 = create_recording({ viewed: false }, site: site, visitor: create_visitor)
        recording_2 = create_recording({ viewed: true }, site: site, visitor: create_visitor)
        [recording_1.id, recording_2.id]
      end

      let(:filters) do
        {
          status: 'New'
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording_ids }

      it 'returns the expected params' do
        output = instance.build
  
        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site.id } }
              }
            ],
            must_not: [
              {
                terms: { id:  [recording_ids.last] }
              }
            ]
          }  
        )
      end
    end

    context 'and the status is viewed' do
      let(:site) { create_site }
      let(:search) { '' }

      let(:recording_ids) do
        recording_1 = create_recording({ viewed: false }, site: site, visitor: create_visitor)
        recording_2 = create_recording({ viewed: true }, site: site, visitor: create_visitor)
        [recording_1.id, recording_2.id]
      end

      let(:filters) do
        {
          status: 'Viewed'
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording_ids }

      it 'returns the expected params' do
        output = instance.build
  
        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site.id } }
              },
              {
                terms: { id: [recording_ids.last] }
              }
            ],
            must_not: []
          }  
        )
      end
    end
  end

  context 'when a date filter is applied' do
    context 'and the range is between dates' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          date: {
            range_type: 'Between',
            between_from_date: '00/00/0000',
            between_to_date: '11/11/1111'
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  date_time: {
                    gte: '0000-00-00',
                    lte: '1111-11-11'
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end

    context 'and the range is before a date' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          date: {
            range_type: 'From',
            from_type: 'Before',
            from_date: '00/00/0000'
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  date_time: {
                    lte: '0000-00-00'
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end

    context 'and the range is after a date' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          date: {
            range_type: 'From',
            from_type: 'After',
            from_date: '00/00/0000'
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  date_time: {
                    gte: '0000-00-00'
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end
  end

  context 'when a duration filter is applied' do
    context 'and the range is between durations' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          duration: {
            range_type: 'Between',
            between_from_duration: 0,
            between_to_duration: 1
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  duration: {
                    gte: 0,
                    lte: 1
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end

    context 'and the range is less than a duration' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          duration: {
            range_type: 'From',
            from_type: 'LessThan',
            from_duration: 1
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  duration: {
                    lte: 1
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end

    context 'and the range is greater than a duration' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          duration: {
            range_type: 'From',
            from_type: 'GreaterThan',
            from_duration: 0
          }
        }
      end

      let(:instance) { described_class.new(site_id, search, filters) }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site_id } }
              },
              {
                range: {
                  duration: {
                    gte: 0
                  }
                }
              }
            ],
            must_not: []
          }  
        )
      end
    end
  end

  context 'when a viewport filter is applied' do
    let(:site_id) { 'site_id' }
    let(:search) { '' }

    let(:filters) do
      {
        viewport: {
          min_width: 0,
          max_width: 1,
          min_height: 0,
          max_height: 1
        }
      }
    end

    let(:instance) { described_class.new(site_id, search, filters) }

    it 'returns the expected params' do
      output = instance.build

      expect(output).to eq(
        bool: {
          must: [
            {
              term: { site_id: { value: site_id } }
            },
            {
              range: {
                'device.device_x' => {
                  gte: 0,
                  lte: 1
                }
              }
            },
            {
              range: {
                'device.device_y' => {
                  gte: 0,
                  lte: 1
                }
              }
            }
          ],
          must_not: []
        }  
      )
    end
  end
end
