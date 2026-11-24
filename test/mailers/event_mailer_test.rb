require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  test "organizer_welcome" do
    event = events(:christmas_2024)
    mail = EventMailer.organizer_welcome(event)

    assert_equal "Your Secret Santa Event: #{event.name}", mail.subject
    assert_equal [ event.organizer_email ], mail.to
    assert_equal [ "noreply@gronare.com" ], mail.from
    assert_match event.name, mail.body.encoded
    assert_match "Manage Your Event", mail.body.encoded
  end
end
