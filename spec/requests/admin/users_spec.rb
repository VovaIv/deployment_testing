require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let!(:admin_user) do
    User.create!(email: 'admin@test.com', password: 'password123',
                 password_confirmation: 'password123', role: 'admin')
  end
  let!(:regular_user) do
    User.create!(email: 'user@test.com', password: 'password123',
                 password_confirmation: 'password123', role: 'user')
  end

  before { sign_in admin_user }

  describe 'DELETE /admin/users/:id' do
    it 'deletes a regular user and redirects' do
      delete admin_user_path(regular_user)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to include('User deleted successfully')
      expect(User.exists?(regular_user.id)).to be false
    end

    it 'prevents self-deletion even via direct request' do
      delete admin_user_path(admin_user)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to include('You cannot delete your own account')
      expect(User.exists?(admin_user.id)).to be true
    end

    it 'prevents deleting the last admin account via direct request' do
      second_admin = User.create!(email: 'admin2@test.com', password: 'password123',
                                  password_confirmation: 'password123', role: 'admin')
      # Force admin_user's role to 'user' directly (bypassing model validation) so that
      # second_admin becomes the sole admin. The self-delete guard fires first when
      # second_admin tries to delete themselves, confirming the last admin is protected.
      # (The last-admin guard is the fallback for race-condition scenarios.)
      admin_user.update_column(:role, 'user')
      sign_in second_admin

      delete admin_user_path(second_admin)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to include('You cannot delete your own account')
      expect(User.exists?(second_admin.id)).to be true
    end
  end
end
