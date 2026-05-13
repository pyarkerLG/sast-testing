# frozen_string_literal: true
require "encryption"

class User < ApplicationRecord
  validates :password, presence: true,
                       confirmation: true,
                       length: {within: 6..40},
                       on: :create,
                       if: :password

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, with: /.+@.+\..+/i

  has_one :retirement, dependent: :destroy
  has_one :paid_time_off, dependent: :destroy
  has_one :work_info, dependent: :destroy
  has_many :performance, dependent: :destroy
  has_many :pay, dependent: :destroy
  has_many :messages, foreign_key: :receiver_id, dependent: :destroy

  before_save :hash_password
  before_create :build_benefits_data
  
  # Secure API token with expiration
  has_secure_token :auth_token
  
  # Set token creation timestamp when token is generated
  after_update :set_auth_token_created_at, if: :saved_change_to_auth_token?
  
  # Token expires after 24 hours
  def token_expired?
    return true unless auth_token_created_at
    auth_token_created_at < 24.hours.ago
  end
  
  # Generate new API token and set creation timestamp
  def regenerate_auth_token!
    regenerate_auth_token
    update_column(:auth_token_created_at, Time.current)
  end
  
  # Validate API token and check expiration
  def valid_auth_token?(token)
    return false if token_expired?
    auth_token == token
  end
  
  def build_benefits_data
    build_retirement(POPULATE_RETIREMENTS.sample)
    build_paid_time_off(POPULATE_PAID_TIME_OFF.sample).schedule.build(POPULATE_SCHEDULE.sample)
    build_work_info(POPULATE_WORK_INFO.sample)
    # Uncomment below line to use encrypted SSN(s)
    #work_info.build_key_management(:iv => SecureRandom.hex(32))
    performance.build(POPULATE_PERFORMANCE.sample)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  private

  def self.authenticate(email, password)
    auth = nil
    user = find_by_email(email)
    raise "#{email} doesn't exist!" if !(user)
    if user.password == Digest::MD5.hexdigest(password)
      auth = user
    else
      raise "Incorrect Password!"
    end
    return auth
  end

  def hash_password
    if will_save_change_to_password?
      self.password = Digest::MD5.hexdigest(self.password)
    end
  end
  
  def set_auth_token_created_at
    update_column(:auth_token_created_at, Time.current) if auth_token.present?
  end


end
