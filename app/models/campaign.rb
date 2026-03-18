class Campaign
  # Campaign model for donation campaigns
  attr_accessor :id, :title, :description, :goal, :deadline, :category, :created_at

  def initialize(id: nil, title:, description:, goal:, deadline:, category:, created_at: nil)
    @id = id
    @title = title
    @description = description
    @goal = goal
    @deadline = deadline
    @category = category
    @created_at = created_at
  end
end
