# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitorsQuery do
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

  context 'and a status filter is applied' do
    context 'and the status is new' do
      let(:site) { create_site }
      let(:search) { '' }
      let(:recording) { create_recording({ viewed: true }, site: site, visitor: create_visitor) }

      let(:filters) do
        {
          status: 'New'
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording }

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
                terms: { id: [recording.visitor.id] }
              }
            ]
          }  
        )
      end
    end

    context 'and the status is viewed' do
      let(:site) { create_site }
      let(:search) { '' }
      let(:recording) { create_recording({ viewed: true }, site: site, visitor: create_visitor) }

      let(:filters) do
        {
          status: 'Viewed'
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site.id } }
              },
              {
                terms: { id: [recording.visitor.id] }
              }
            ],
            must_not: []
          }  
        )
      end
    end
  end

  context 'when a recordings count filter is applied' do
    context 'and the count is less than' do
      let(:site) { create_site }
      let(:search) { '' }
      let(:recording) { create_recording(site: site, visitor: create_visitor) }

      let(:filters) do
        {
          recordings: {
            range_type: 'LessThan',
            count: 2
          }
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site.id } }
              },
              {
                terms: { id: [recording.visitor.id] }
              }
            ],
            must_not: []
          }  
        )
      end
    end

    context 'and the count is greater than' do
      let(:site) { create_site }
      let(:search) { '' }
      let(:recording) { create_recording(site: site, visitor: create_visitor) }

      let(:filters) do
        {
          recordings: {
            range_type: 'GreaterThan',
            count: 0
          }
        }
      end

      let(:instance) { described_class.new(site.id, search, filters) }

      before { recording }

      it 'returns the expected params' do
        output = instance.build

        expect(output).to eq(
          bool: {
            must: [
              {
                term: { site_id: { value: site.id } }
              },
              {
                terms: { id: [recording.visitor.id] }
              }
            ],
            must_not: []
          }  
        )
      end
    end
  end

  context 'when a first viewed filter is applied' do
    context 'and the range is between dates' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          first_visited: {
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
                  first_viewed_at: {
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
          first_visited: {
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
                  first_viewed_at: {
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
          first_visited: {
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
                  first_viewed_at: {
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

  context 'when a last activity filter is applied' do
    context 'and the range is between dates' do
      let(:site_id) { 'site_id' }
      let(:search) { '' }

      let(:filters) do
        {
          last_activity: {
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
                  last_activity_at: {
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
          last_activity: {
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
                  last_activity_at: {
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
          last_activity: {
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
                  last_activity_at: {
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
end
