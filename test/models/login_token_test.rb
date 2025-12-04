require "test_helper"

class LoginTokenTest < ActiveSupport::TestCase
  test "should generate token on creation" do
    participant = participants(:alice)
    token = LoginToken.create!(participant: participant)
    assert_not_nil token.token
    assert token.token.length > 0
  end

  test "should set expiration on creation" do
    participant = participants(:alice)
    token = LoginToken.create!(participant: participant)
    assert_not_nil token.expires_at
    assert token.expires_at > Time.current
  end

  test "should validate token uniqueness" do
    participant = participants(:alice)
    token1 = LoginToken.create!(participant: participant)
    token2 = LoginToken.new(
      participant: participant,
      token: token1.token,
      expires_at: 1.day.from_now
    )
    assert_not token2.save
  end

  test "should be active when not expired and not used" do
    token = login_tokens(:alice_valid_token)
    assert token.active?
  end

  test "should be inactive when expired" do
    token = login_tokens(:bob_expired_token)
    assert_not token.active?
  end

  test "should be inactive when already used" do
    token = login_tokens(:alice_valid_token)
    token.mark_as_used!
    assert_not token.active?
  end

  test "should mark token as used" do
    token = login_tokens(:alice_valid_token)
    assert_nil token.used_at
    token.mark_as_used!
    assert_not_nil token.used_at
  end

  test "active scope should only return active tokens" do
    alice = participants(:alice)
    active_token = LoginToken.create!(participant: alice)
    expired_token = LoginToken.create!(
      participant: alice,
      expires_at: 1.hour.ago
    )
    used_token = LoginToken.create!(participant: alice)
    used_token.mark_as_used!

    active_tokens = LoginToken.active
    assert_includes active_tokens, active_token
    assert_not_includes active_tokens, expired_token
    assert_not_includes active_tokens, used_token
  end

  test "fixture token has association" do
    token = login_tokens(:alice_valid_token)
    assert_not_nil token.participant
    assert_equal participants(:alice), token.participant
  end
end
