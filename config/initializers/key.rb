# frozen_string_literal: true
# WARNING: This key is for development only and should not be used in production
# In production, set the ENCRYPTION_KEY environment variable instead
unless Rails.env.production?
  KEY = "123456789101112123456789101112123456789101112"
end
