require 'spec_helper'
require_relative '../app/models/donation'

RSpec.describe Donation do
  describe '#valid_amount?' do
    it 'returns false for nil and zero amount' do
      nil_amount = Donation.new(campaign_id: 1, donor_id: 1, amount: nil)
      zero_amount = Donation.new(campaign_id: 1, donor_id: 1, amount: 0)

      expect(nil_amount.valid_amount?).to be(false)
      expect(zero_amount.valid_amount?).to be(false)
    end
  end
end
