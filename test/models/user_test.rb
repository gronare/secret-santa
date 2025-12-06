require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with a valid email" do
    user = User.new(email: "test@example.com")
    assert user.valid?
  end

  test "is invalid without an email" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "validates email format" do
    user = User.new(email: "invalid-email")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "enforces email uniqueness" do
    User.create!(email: "unique@example.com")

    duplicate = User.new(email: "unique@example.com")
    assert_not duplicate.valid?
  end

  test "normalizes email" do
    user = User.create!(email: "  TEST@Example.COM ")
    assert_equal "test@example.com", user.email
  end

  test "can generate and verify magic link token" do
    user = User.create!(email: "magic@example.com")

    token = user.generate_token_for(:magic_link)
    assert token.present?

    found = User.find_by_token_for(:magic_link, token)
    assert_equal user, found
  end

  test "magic link token expires" do
    user = User.create!(email: "expiring@example.com")

    token = user.generate_token_for(:magic_link)

    travel 25.hours do
      assert_nil User.find_by_token_for(:magic_link, token)
    end
  end
end
