# frozen_string_literal: true
class WorkInfoController < ApplicationController
  def index
    # Prevent parameter tampering by ensuring users can only access their own work info
    # unless they are admin
    if is_admin? && params[:user_id].present?
      # Admin can access any user's work info with proper validation
      user_id = params[:user_id].to_i
      @user = User.find_by(id: user_id) if user_id > 0
    else
      # Regular users can only access their own work info
      @user = current_user
    end
    
    if !@user
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
    end
  end

end
