# frozen_string_literal: true
class WorkInfoController < ApplicationController
  def index
    @user = User.find_by(id: params[:user_id])
    
    # Check if user exists
    if !@user
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
      return
    end
    
    # Check if user is admin (admins cannot have work info viewed)
    if @user.admin
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
      return
    end
    
    # Authorization check: only allow access to own work info or if current user is admin
    unless current_user.id == @user.id || is_admin?
      flash[:error] = "You are not authorized to view this information"
      redirect_to home_dashboard_index_path
      return
    end
  end

end
