class User
  # User model for donors and campaign creators
  attr_accessor :id, :email, :name, :password_hash, :created_at

  def initialize(id: nil, email:, name:, password_hash:, created_at: nil)
    @id = id
    @email = email
    @name = name
    @password_hash = password_hash
    @created_at = created_at
  end
end
