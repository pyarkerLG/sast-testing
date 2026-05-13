# frozen_string_literal: true
class UsersController < ApplicationController
  skip_before_action :has_info
  skip_before_action :authenticated, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to home_dashboard_index_path
    else
      @user = user
      flash[:error] = user.errors.full_messages.to_sentence
      redirect_to :signup
    end
  end

  def account_settings
    @user = current_user
  end

  def update
    message = false

    # Authorization: Only allow users to update their own profile, or admins to update any profile
    target_user_id = params[:user][:id]
    
    if target_user_id.to_s != current_user.id.to_s && !is_admin?
      flash[:error] = "You are not authorized to update this user!"
      redirect_to user_account_settings_path(user_id: current_user.id)
      return
    end

    # Fix SQL injection by using proper parameter binding
    user = User.find_by(id: target_user_id)

    if user
      # Use different parameter methods based on admin status
      if is_admin?
        user.update(admin_user_params_without_password)
      else
        user.update(user_params_without_password)
      end
      
      if params[:user][:password].present? && (params[:user][:password] == params[:user][:password_confirmation])
        user.password = params[:user][:password]
      end
      message = true if user.save!
      respond_to do |format|
        format.html { redirect_to user_account_settings_path(user_id: current_user.id) }
        format.json { render json: {msg: message ? "success" : "false "} }
      end
    else
      flash[:error] = "Could not update user!"
      redirect_to user_account_settings_path(user_id: current_user.id)
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  # unpermitted attributes are ignored in production
  def user_params_without_password
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  # Admin-only parameter method that allows updating admin status
  def admin_user_params_without_password
    params.require(:user).permit(:email, :admin, :first_name, :last_name)
  end
end
