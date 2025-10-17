# frozen_string_literal: true
class Schedule < ApplicationRecord
  belongs_to :paid_time_off

  validates_presence_of :date_begin, :date_end, :event_desc, :event_name, :event_type

  # Scope to restrict access to schedules that belong to the user
  scope :accessible_by_user, ->(user) { 
    joins(:paid_time_off).where(paid_time_offs: { user_id: user.id }) 
  }
end
