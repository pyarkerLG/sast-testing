# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# Load secret_key_base from environment variable for security
Railsgoat::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || 
  raise('SECRET_KEY_BASE environment variable must be set')
