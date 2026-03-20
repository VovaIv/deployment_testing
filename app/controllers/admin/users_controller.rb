module Admin
  class UsersController < ApplicationController
    include AdminAuthorizable

    before_action :require_admin
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.select(:id, :email, :role, :created_at).order(:email).paginate(page: params[:page], per_page: 25)
      @admin_count = User.where(role: 'admin').count
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params.except(:password, :password_confirmation))
      @user.password = SecureRandom.hex(16)
      if @user.save
        @user.send_reset_password_instructions
        Rails.logger.info("[ADMIN AUDIT] #{sanitize_log(current_user.email)} created user #{sanitize_log(@user.email)} with role: #{sanitize_log(@user.role)}")
        redirect_to admin_users_path, notice: 'User created. A password setup email has been sent.'
      else
        Rails.logger.warn("[ADMIN AUDIT] #{sanitize_log(current_user.email)} failed to create user: #{sanitize_log(@user.errors.full_messages.join(', '))}")
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      update_params = user_params
      if update_params[:password].blank?
        update_params = update_params.except(:password, :password_confirmation)
      end

      if @user == current_user
        update_params = update_params.except(:role)
      end

      if @user.update(update_params)
        Rails.logger.info("[ADMIN AUDIT] #{sanitize_log(current_user.email)} updated user #{sanitize_log(@user.email)} — role: #{sanitize_log(@user.role)}")
        redirect_to admin_users_path, notice: 'User updated successfully.'
      else
        Rails.logger.warn("[ADMIN AUDIT] #{sanitize_log(current_user.email)} failed to update user #{sanitize_log(@user.email)}: #{sanitize_log(@user.errors.full_messages.join(', '))}")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: 'You cannot delete your own account.'
        return
      end

      last_admin_blocked = false

      ApplicationRecord.transaction do
        if @user.admin? && !User.lock.where(role: 'admin').where.not(id: @user.id).exists?
          last_admin_blocked = true
          raise ActiveRecord::Rollback
        end
        @user.destroy!
      end

      if last_admin_blocked
        redirect_to admin_users_path, alert: 'Cannot delete the last admin account.'
      else
        Rails.logger.info("[ADMIN AUDIT] #{sanitize_log(current_user.email)} deleted user #{sanitize_log(@user.email)}")
        redirect_to admin_users_path, notice: 'User deleted successfully.'
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end
  end
end
