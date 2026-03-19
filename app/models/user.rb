class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Role validation
  validates :role, presence: true, inclusion: { in: %w[user admin] }
  validate :cannot_demote_last_admin, on: :update

  # Check if user is an admin
  def admin?
    role == 'admin'
  end

  private

  def cannot_demote_last_admin
    return unless role_changed? && role == 'user' && role_was == 'admin'

    remaining = User.lock.where(role: 'admin').where.not(id: id).count
    errors.add(:role, 'cannot remove the last admin account') if remaining < 1
  end
end
