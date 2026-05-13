# frozen_string_literal: true
class Api::V1::MobileController < ApplicationController
  before_action :mobile_request?
  before_action :validate_model_access

  respond_to :json

  # Whitelist of models that can be accessed via mobile API
  ALLOWED_MODELS = %w[Schedule Message].freeze

  def show
    if params[:class] && params[:id]
      model = get_allowed_model(params[:class])
      return render json: { error: 'Unauthorized model access' }, status: :forbidden unless model
      
      record = model.find_by(id: params[:id])
      return render json: { error: 'Record not found' }, status: :not_found unless record
      
      # Only allow access to records owned by current user
      return render json: { error: 'Access denied' }, status: :forbidden unless can_access_record?(record)
      
      respond_with record.to_json
    else
      render json: { error: 'Missing required parameters' }, status: :bad_request
    end
  end

  def index
    if params[:class]
      model = get_allowed_model(params[:class])
      return render json: { error: 'Unauthorized model access' }, status: :forbidden unless model
      
      # Only return records accessible to current user
      records = get_user_accessible_records(model)
      respond_with records.to_json
    else
      render json: { error: 'Missing class parameter' }, status: :bad_request
    end
  end

  private

  def mobile_request?
    unless session[:mobile_param] == "1" || request.user_agent =~ /ios|android/i
      render json: { error: 'Mobile access required' }, status: :forbidden
      false
    end
  end

  def validate_model_access
    return unless params[:class]
    
    unless ALLOWED_MODELS.include?(params[:class].classify)
      render json: { error: 'Model not allowed for mobile access' }, status: :forbidden
    end
  end

  def get_allowed_model(class_name)
    classified_name = class_name.classify
    return nil unless ALLOWED_MODELS.include?(classified_name)
    
    begin
      classified_name.constantize
    rescue NameError
      nil
    end
  end

  def can_access_record?(record)
    # Implement record-level authorization based on your business logic
    # For now, assuming records have a user_id or similar association
    return true if record.respond_to?(:user_id) && record.user_id == current_user.id
    return true if record.respond_to?(:user) && record.user == current_user
    
    # For models without user association, deny access for security
    false
  end

  def get_user_accessible_records(model)
    # Return only records accessible to current user
    if model.column_names.include?('user_id')
      model.where(user_id: current_user.id)
    elsif model.reflect_on_association(:user)
      model.where(user: current_user)
    else
      # For models without user association, return empty collection for security
      model.none
    end
  end
end
