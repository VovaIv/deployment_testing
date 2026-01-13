class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Role validation
  validates :role, presence: true, inclusion: { in: %w[user admin] }

  # Check if user is an admin
  def admin?
    role == 'admin'
  end
end
