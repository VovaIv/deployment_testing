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

    describe 'last admin protection' do
      let!(:admin) { User.create!(email: 'admin@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }

      it 'prevents demoting the last admin' do
        admin.role = 'user'
        expect(admin).not_to be_valid
        expect(admin.errors[:role]).to include('cannot remove the last admin account')
      end

      it 'allows demoting an admin when another admin exists' do
        User.create!(email: 'admin2@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin')
        admin.role = 'user'
        expect(admin).to be_valid
      end

      it 'does not fire on create' do
        new_admin = User.new(email: 'new@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin')
        expect(new_admin).to be_valid
      end

      it 'does not fire when role is unchanged' do
        admin.email = 'changed@test.com'
        expect(admin).to be_valid
      end
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
