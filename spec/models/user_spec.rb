require 'rails_helper'

describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', role: 'user')
      expect(user).to be_valid
    end

    it 'requires an email' do
      user = User.new(password: 'password123', password_confirmation: 'password123', role: 'user')
      expect(user).not_to be_valid
    end

    it 'requires a role' do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', role: nil)
      expect(user).not_to be_valid
    end

    it 'only allows valid roles' do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', role: 'invalid_role')
      expect(user).not_to be_valid
    end

    it 'defaults to user role' do
      user = User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user.role).to eq('user')
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      admin = User.new(role: 'admin')
      expect(admin.admin?).to be true
    end

    it 'returns false for regular users' do
      user = User.new(role: 'user')
      expect(user.admin?).to be false
    end
  end
end
