require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "magic_link" do
    mail = UserMailer.magic_link(users(:alice), "http://example.com/magic_link_token")
    assert_equal "Your Secret Santa login link", mail.subject
    assert_equal [ "alice@example.com" ], mail.to
    assert_equal [ "noreply@secretsanta.gronare.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
