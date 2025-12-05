require "test_helper"

class ParticipantMailerTest < ActionMailer::TestCase
  test "invitation" do
    mail = ParticipantMailer.invitation
    assert_equal "Invitation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "assignment" do
    mail = ParticipantMailer.assignment
    assert_equal "Assignment", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
