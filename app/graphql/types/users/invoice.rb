# frozen_string_literal: true

module Types
  module Users
    class Invoice < Types::BaseObject
      graphql_name 'UsersInvoice'

      field :id, ID, null: false
      field :filename, String, null: false
      field :invoice_url, String, null: false
      field :status, Integer, null: false
      field :amount, Float, null: false
      field :currency, Types::Common::Currency, null: false
      field :issued_at, Types::Common::Dates, null: true
      field :due_at, Types::Common::Dates, null: true
      field :paid_at, Types::Common::Dates, null: true

      def issued_at
        DateFormatter.format(date: object.issued_at, timezone: context[:timezone])
      end

      def due_at
        DateFormatter.format(date: object.due_at, timezone: context[:timezone])
      end

      def paid_at
        DateFormatter.format(date: object.paid_at, timezone: context[:timezone])
      end
    end
  end
end
