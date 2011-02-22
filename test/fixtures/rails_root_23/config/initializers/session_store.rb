# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_active_assets_test_session',
  :secret      => '024e7ddcd58af0c57d0388cf23cfcc8d3b3c32e2463fdbade15458c2e0a16f8ad346589e4352ca023c440b8a288b0c1c4ed92ee647768831f1d8bb8ba1ae2a8e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
