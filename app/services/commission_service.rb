# frozen_string_literal: true

class CommissionService
  COMMISSION_RATE = 0.2

  def initialize(partner)
    @partner = partner
  end

  def all_time_commission
    transactions.map do |transaction|
      {
        id: transaction.id,
        amount: discounted_amount(transaction) * COMMISSION_RATE,
        currency: transaction.currency,
        site_id: transaction.billing.site_id
      }
    end
  end

  def pay_outs
    paid_invoices.map do |invoice|
      {
        id: invoice.id,
        amount: invoice.amount,
        currency: invoice.currency
      }
    end
  end

  private

  attr_reader :partner

  def sites
    @sites ||= partner.sites
  end

  def site_ids
    sites.map(&:id)
  end

  def paid_invoices
    @paid_invoices ||= partner.invoices.where(status: PartnerInvoice::PAID)
  end

  def billings
    @billings ||= Billing.where(site_id: site_ids).includes(:transactions)
  end

  def transactions
    @transactions ||= billings.flat_map(&:transactions).reject { |transaction| transaction.amount.negative? }
  end

  def discounted_amount(transaction)
    return transaction.amount unless transaction.discount_percentage

    (transaction.discount_percentage.to_f / 100) * transaction.amount
  end
end
