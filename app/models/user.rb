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

    # NOTE: SELECT FOR UPDATE is silently ignored by SQLite (used in dev/test).
    # This pessimistic lock is only effective in PostgreSQL-backed production.
    no_other_admins = !User.lock.where(role: 'admin').where.not(id: id).exists?
    errors.add(:role, 'cannot remove the last admin account') if no_other_admins
  end
end
