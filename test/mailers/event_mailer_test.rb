require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  test "organizer_welcome" do
    mail = EventMailer.organizer_welcome
    assert_equal "Organizer welcome", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
