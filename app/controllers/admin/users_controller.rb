class Admin::UsersController < ApplicationController
  include AdminAuthorizable

  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.select(:id, :email, :role, :created_at).order(:email).paginate(page: params[:page], per_page: 25)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Rails.logger.info("[ADMIN AUDIT] #{current_user.email} created user #{@user.email} with role: #{@user.role}")
      redirect_to admin_users_path, notice: 'User created successfully.'
    else
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
      Rails.logger.info("[ADMIN AUDIT] #{current_user.email} updated user #{@user.email} — role: #{@user.role}")
      redirect_to admin_users_path, notice: 'User updated successfully.'
    else
      render :edit, status: :unprocessable_entity
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
