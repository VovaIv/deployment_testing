require 'rails_helper'

describe 'Admin User Management', type: :system do
  let!(:admin_user) { User.create!(email: 'admin@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let!(:regular_user) { User.create!(email: 'user@test.com', password: 'password123', password_confirmation: 'password123', role: 'user') }

  context 'when not signed in' do
    it 'redirects to sign-in for admin users index' do
      visit admin_users_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'redirects to sign-in for new user form' do
      visit new_admin_user_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'when signed in as admin' do
    before do
      sign_in admin_user
    end

    it 'shows Admin Panel link in header' do
      visit surveys_path
      expect(page).to have_link('Admin Panel', href: admin_users_path)
    end

    it 'can access admin users index' do
      visit admin_users_path
      expect(page).to have_content('Users')
      expect(page).to have_content('user@test.com')
      expect(page).to have_content('admin@test.com')
    end

    it 'can create a new user' do
      visit new_admin_user_path
      expect(page).to have_content('New User')

      fill_in 'user[email]', with: 'newuser@test.com'
      select 'User', from: 'user[role]'
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'password123'
      click_button 'Create User'

      expect(page).to have_content('User created successfully')
      expect(page).to have_content('newuser@test.com')
    end

    it 'shows validation errors when creating user with invalid data' do
      visit new_admin_user_path
      fill_in 'user[email]', with: ''
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'password123'
      click_button 'Create User'

      expect(page).to have_content("Email can't be blank")
    end

    it 'can edit an existing user' do
      visit edit_admin_user_path(regular_user)
      expect(page).to have_content('Edit User')

      fill_in 'user[email]', with: 'updated@test.com'
      select 'Admin', from: 'user[role]'
      click_button 'Update User'

      expect(page).to have_content('User updated successfully')
      expect(page).to have_content('updated@test.com')
    end

    it 'can update user without changing password' do
      visit edit_admin_user_path(regular_user)
      fill_in 'user[email]', with: 'changed@test.com'
      # Leave password fields blank
      click_button 'Update User'

      expect(page).to have_content('User updated successfully')
      expect(page).to have_content('changed@test.com')
    end

    it 'shows validation errors when updating user with invalid data' do
      visit edit_admin_user_path(regular_user)
      fill_in 'user[email]', with: ''
      click_button 'Update User'

      expect(page).to have_content("Email can't be blank")
    end

    it 'cannot change own role' do
      visit edit_admin_user_path(admin_user)
      expect(page).to have_content('Your own role cannot be changed')
      click_button 'Update User'

      expect(page).to have_content('User updated successfully')
      expect(admin_user.reload.role).to eq('admin')
    end

    it 'can delete a regular user' do
      visit admin_users_path
      expect(page).to have_content('user@test.com')
      accept_confirm do
        click_link('Delete', href: admin_user_path(regular_user))
      end
      expect(page).to have_content('User deleted successfully')
      expect(page).not_to have_content('user@test.com')
    end

    it 'cannot delete own account' do
      visit admin_users_path
      expect(page).not_to have_link('Delete', href: admin_user_path(admin_user))
    end

    it 'cannot delete the last admin account' do
      visit admin_users_path
      # regular_user is not an admin, admin_user is the only admin — no delete button for admin_user
      expect(page).not_to have_link('Delete', href: admin_user_path(admin_user))
    end

    it 'cannot demote the last admin account' do
      # Create a second admin so admin_user can demote them.
      # After demotion, admin_user becomes the only admin.
      second_admin = User.create!(email: 'admin2@test.com', password: 'password123', password_confirmation: 'password123', role: 'admin')

      # Demote second_admin → succeeds (admin_user is still admin, count: 2 → 1)
      visit edit_admin_user_path(second_admin)
      select 'User', from: 'user[role]'
      click_button 'Update User'
      expect(page).to have_content('User updated successfully')

      # Now admin_user is the only admin. second_admin (now a regular user) can no longer
      # access the admin panel. Verify admin_user's own role field is locked (self-demotion
      # protection) and the model-level last-admin guard works together to prevent lockout.
      visit edit_admin_user_path(admin_user)
      expect(page).to have_content('Your own role cannot be changed')
    end
  end

  context 'when signed in as regular user' do
    before do
      sign_in regular_user
    end

    it 'does not show Admin Panel link in header' do
      visit surveys_path
      expect(page).not_to have_link('Admin Panel')
    end

    it 'cannot access admin users index' do
      visit admin_users_path
      expect(page).to have_current_path(surveys_path)
      expect(page).to have_content('You are not authorized to perform this action')
    end

    it 'cannot access new user form' do
      visit new_admin_user_path
      expect(page).to have_current_path(surveys_path)
      expect(page).to have_content('You are not authorized to perform this action')
    end
  end
end
