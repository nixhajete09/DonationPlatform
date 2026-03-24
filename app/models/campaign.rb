# frozen_string_literal: true

class Campaign
  # Campaign model for donation campaigns
  attr_accessor :id, :title, :description, :goal, :deadline, :category, :image_url, :created_at

  def initialize(title:, description:, goal:, deadline:, category:, id: nil, image_url: nil, created_at: nil)
    @id = id
    @title = title
    @description = description
    @goal = goal
    @deadline = deadline
    @category = category
    @image_url = image_url
    @created_at = created_at
  end
end
