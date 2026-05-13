# frozen_string_literal: true
ACCESS_TOKEN_SALT = ENV['ACCESS_TOKEN_SALT'] || raise("ACCESS_TOKEN_SALT environment variable is required")

RG_IV = ENV['RG_IV'] || raise("RG_IV environment variable is required")
