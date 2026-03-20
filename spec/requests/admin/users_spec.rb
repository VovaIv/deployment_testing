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

  # ── Authentication / authorization guards ─────────────────────────────────

  shared_examples 'redirects unauthenticated requests' do |method, path_proc|
    it 'redirects unauthenticated users to sign-in' do
      send(method, instance_exec(&path_proc))
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  shared_examples 'redirects non-admin requests' do |method, path_proc|
    before { sign_in regular_user }

    it 'redirects non-admin users away' do
      send(method, instance_exec(&path_proc))
      expect(response).to redirect_to(surveys_path)
    end
  end

  # ── GET /admin/users ───────────────────────────────────────────────────────

  describe 'GET /admin/users' do
    include_examples 'redirects unauthenticated requests', :get, -> { admin_users_path }
    include_examples 'redirects non-admin requests',      :get, -> { admin_users_path }

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'returns 200 and lists users' do
        get admin_users_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(admin_user.email)
        expect(response.body).to include(regular_user.email)
      end
    end
  end

  # ── GET /admin/users/new ──────────────────────────────────────────────────

  describe 'GET /admin/users/new' do
    include_examples 'redirects unauthenticated requests', :get, -> { new_admin_user_path }
    include_examples 'redirects non-admin requests',      :get, -> { new_admin_user_path }

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'returns 200' do
        get new_admin_user_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ── POST /admin/users ─────────────────────────────────────────────────────

  describe 'POST /admin/users' do
    include_examples 'redirects unauthenticated requests', :post, -> { admin_users_path }
    include_examples 'redirects non-admin requests',      :post, -> { admin_users_path }

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'creates a user with valid params and sends password-reset email' do
        expect {
          post admin_users_path, params: { user: { email: 'new@test.com', role: 'user' } }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(admin_users_path)
        follow_redirect!
        expect(response.body).to include('password setup email')
      end

      it 'assigns the requested role' do
        post admin_users_path, params: { user: { email: 'newadmin@test.com', role: 'admin' } }
        expect(User.find_by(email: 'newadmin@test.com').role).to eq('admin')
      end

      it 'renders new with 422 on validation error' do
        post admin_users_path, params: { user: { email: admin_user.email, role: 'user' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ── GET /admin/users/:id/edit ─────────────────────────────────────────────

  describe 'GET /admin/users/:id/edit' do
    include_examples 'redirects unauthenticated requests', :get, -> { edit_admin_user_path(regular_user) }
    include_examples 'redirects non-admin requests',      :get, -> { edit_admin_user_path(regular_user) }

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'returns 200' do
        get edit_admin_user_path(regular_user)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ── PATCH /admin/users/:id ────────────────────────────────────────────────

  describe 'PATCH /admin/users/:id' do
    include_examples 'redirects unauthenticated requests', :patch, -> { admin_user_path(regular_user) }
    include_examples 'redirects non-admin requests',      :patch, -> { admin_user_path(regular_user) }

    context 'when signed in as admin' do
      before { sign_in admin_user }

      it 'updates email and redirects' do
        patch admin_user_path(regular_user),
              params: { user: { email: 'updated@test.com', role: 'user' } }
        expect(response).to redirect_to(admin_users_path)
        expect(regular_user.reload.email).to eq('updated@test.com')
      end

      it 'updates password when provided' do
        patch admin_user_path(regular_user),
              params: { user: { email: regular_user.email, role: 'user',
                                password: 'newpassword1', password_confirmation: 'newpassword1' } }
        expect(response).to redirect_to(admin_users_path)
        expect(regular_user.reload.valid_password?('newpassword1')).to be true
      end

      it 'does not overwrite password when left blank' do
        old_encrypted = regular_user.encrypted_password
        patch admin_user_path(regular_user),
              params: { user: { email: regular_user.email, role: 'user',
                                password: '', password_confirmation: '' } }
        expect(regular_user.reload.encrypted_password).to eq(old_encrypted)
      end

      it 'does not allow an admin to change their own role' do
        patch admin_user_path(admin_user),
              params: { user: { email: admin_user.email, role: 'user' } }
        expect(admin_user.reload.role).to eq('admin')
      end

      it 'renders edit with 422 on validation error' do
        patch admin_user_path(regular_user),
              params: { user: { email: '', role: 'user' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ── DELETE /admin/users/:id ───────────────────────────────────────────────

  describe 'DELETE /admin/users/:id' do
    include_examples 'redirects unauthenticated requests', :delete, -> { admin_user_path(regular_user) }
    include_examples 'redirects non-admin requests',      :delete, -> { admin_user_path(regular_user) }

    context 'when signed in as admin' do
      before { sign_in admin_user }

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

      it 'prevents deleting the sole remaining admin' do
        second_admin = User.create!(email: 'admin2@test.com', password: 'password123',
                                    password_confirmation: 'password123', role: 'admin')
        # Sign in as second_admin and try to delete admin_user who is the only other admin
        sign_in second_admin
        delete admin_user_path(admin_user)
        expect(response).to redirect_to(admin_users_path)
        follow_redirect!
        expect(response.body).to include('Cannot delete the last admin account')
        expect(User.exists?(admin_user.id)).to be true
      end

      it 'allows deleting a non-sole admin (last-admin guard does not fire)' do
        second_admin = User.create!(email: 'admin2@test.com', password: 'password123',
                                    password_confirmation: 'password123', role: 'admin')
        # Two admins exist; deleting second_admin leaves admin_user as sole admin — allowed.
        delete admin_user_path(second_admin)
        expect(response).to redirect_to(admin_users_path)
        follow_redirect!
        expect(response.body).to include('User deleted successfully')
        expect(User.exists?(second_admin.id)).to be false
      end
    end
  end
end
