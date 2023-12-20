# frozen_string_literal: true

module WeeklyReviewService
  class Generator
    def initialize(site_id:, from_date:, to_date:)
      @site_id = site_id
      @from_date = from_date
      @to_date = to_date
    end

    def site
      @site ||= Site.find(site_id)
    end

    def members
      site.team
    end

    def to_h
      @to_h ||= {
        total_visitors:,
        new_visitors:,
        total_recordings:,
        new_recordings:,
        average_session_duration:,
        average_session_duration_trend:,
        pages_per_session:,
        pages_per_session_trend:,
        busiest_day:,
        biggest_referrer_url:,
        most_popular_country:,
        most_popular_browser:,
        most_popular_visitor:,
        most_popular_page_url:,
        feedback_nps:,
        feedback_nps_trend:,
        feedback_sentiment:,
        feedback_sentiment_trend:
      }
    end

    private

    attr_reader :site_id, :from_date, :to_date

    def range
      @range ||= DateRange.new(from_date: @from_date, to_date: @to_date)
    end

    def total_visitors
      TotalVisitors.fetch(site, range.from, range.to)
    end

    def new_visitors
      NewVisitors.fetch(site, range.from, range.to)
    end

    def total_recordings
      TotalRecordings.fetch(site, range.from, range.to)
    end

    def new_recordings
      NewRecordings.fetch(site, range.from, range.to)
    end

    def average_session_duration
      @average_session_duration ||= AverageSessionDuration.fetch(site, range.from, range.to)
    end

    def average_session_duration_trend
      previous = AverageSessionDuration.fetch(site, range.trend_from, range.trend_to)

      {
        trend: milliseconds_to_mmss(average_session_duration - previous),
        direction: average_session_duration >= previous ? 'up' : 'down'
      }
    end

    def pages_per_session
      @pages_per_session ||= PagesPerSession.fetch(site, range.from, range.to)
    end

    def pages_per_session_trend
      previous = PagesPerSession.fetch(site, range.trend_from, range.trend_to)

      {
        trend: Maths.to_two_decimal_places(pages_per_session - previous),
        direction: pages_per_session >= previous ? 'up' : 'down'
      }
    end

    def busiest_day
      BusiestDay.fetch(site, range.from, range.to)
    end

    def biggest_referrer_url
      BiggestReferrerUrl.fetch(site, range.from, range.to)
    end

    def most_popular_country
      MostPopularCountry.fetch(site, range.from, range.to)
    end

    def most_popular_browser
      MostPopularBrowser.fetch(site, range.from, range.to)
    end

    def most_popular_visitor
      MostPopularVisitor.fetch(site, range.from, range.to)
    end

    def most_popular_page_url
      MostPopularPageUrl.fetch(site, range.from, range.to)
    end

    def feedback_nps
      @feedback_nps ||= FeedbackNps.fetch(site, range.from, range.to)
    end

    def feedback_nps_trend
      previous = FeedbackNps.fetch(site, range.trend_from, range.trend_to)

      {
        trend: Maths.to_two_decimal_places(feedback_nps[:score] - previous[:score]),
        direction: feedback_nps[:score] >= previous[:score] ? 'up' : 'down'
      }
    end

    def feedback_sentiment
      @feedback_sentiment ||= FeedbackSentiment.fetch(site, range.from, range.to)
    end

    def feedback_sentiment_trend
      previous = FeedbackSentiment.fetch(site, range.trend_from, range.trend_to)

      {
        trend: Maths.to_two_decimal_places(feedback_sentiment[:score] - previous[:score]),
        direction: feedback_sentiment[:score] >= previous[:score] ? 'up' : 'down'
      }
    end

    def milliseconds_to_mmss(milliseconds = 0)
      Time.at(milliseconds.abs / 1000).utc.strftime('%-Mm %-Ss')
    end
  end
end
