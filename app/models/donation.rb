class Donation
  # Donation model
  attr_accessor :id, :campaign_id, :donor_id, :amount, :anonymous, :created_at

  def initialize(id: nil, campaign_id:, donor_id:, amount:, anonymous: false, created_at: nil)
    @id = id
    @campaign_id = campaign_id
    @donor_id = donor_id
    @amount = amount
    @anonymous = anonymous
    @created_at = created_at
  end
end
