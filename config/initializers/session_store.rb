# Configure session cookie to persist across browser sessions
Rails.application.config.session_store :cookie_store,
  key: "_secret_santa_session",
  expire_after: 30.days
