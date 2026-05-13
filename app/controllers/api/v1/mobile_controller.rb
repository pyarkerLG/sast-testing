# frozen_string_literal: true
class Api::V1::MobileController < ApplicationController
  before_action :mobile_request?

  respond_to :json

  # Whitelist of allowed models for mobile access
  ALLOWED_MODELS = {
    'schedule' => Schedule,
    'message' => Message
  }.freeze

  def show
    if params[:class] && params[:id]
      model_class = get_allowed_model(params[:class])
      return respond_with({ error: 'Unauthorized model access' }.to_json, status: :forbidden) unless model_class
      
      record = find_user_scoped_record(model_class, params[:id])
      return respond_with({ error: 'Record not found' }.to_json, status: :not_found) unless record
      
      respond_with record.to_json
    else
      respond_with({ error: 'Missing required parameters' }.to_json, status: :bad_request)
    end
  end

  def index
    if params[:class]
      model_class = get_allowed_model(params[:class])
      return respond_with({ error: 'Unauthorized model access' }.to_json, status: :forbidden) unless model_class
      
      records = get_user_scoped_records(model_class)
      respond_with records.to_json
    else
      respond_with({ error: 'Missing class parameter' }.to_json, status: :bad_request)
    end
  end

  private

  def get_allowed_model(class_name)
    ALLOWED_MODELS[class_name.downcase]
  end

  def find_user_scoped_record(model_class, record_id)
    # Scope records to current user if the model has a user association
    if model_class.column_names.include?('user_id')
      model_class.where(user_id: current_user.id).find_by(id: record_id)
    else
      # For models without user association, still require authentication but allow access
      model_class.find_by(id: record_id)
    end
  end

  def get_user_scoped_records(model_class)
    # Scope records to current user if the model has a user association
    if model_class.column_names.include?('user_id')
      model_class.where(user_id: current_user.id)
    else
      # For models without user association, still require authentication but allow access
      model_class.all
    end
  end

  def mobile_request?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /ios|android/i
    end
  end
end
