require "test_helper"

class ParticipantMailerTest < ActionMailer::TestCase
  test "invitation" do
    participant = participants(:bob)
    event = participant.event
    mail = ParticipantMailer.invitation(participant)

    assert_equal "You're invited to #{event.name}!", mail.subject
    assert_equal [ participant.email ], mail.to
    assert_equal [ "noreply@gronare.com" ], mail.from
    assert_includes mail.html_part.body.to_s, participant.name
    assert_includes mail.html_part.body.to_s, "You're Invited!"
  end

  test "assignment" do
    alice = participants(:alice)
    bob = participants(:bob)
    alice.update_column(:assigned_to_id, bob.id)

    mail = ParticipantMailer.assignment(alice)

    assert_equal "Your Secret Santa assignment for #{alice.event.name}", mail.subject
    assert_equal [ alice.email ], mail.to
    assert_equal [ "noreply@gronare.com" ], mail.from
    assert_includes mail.html_part.body.to_s, alice.name
    assert_includes mail.html_part.body.to_s, bob.name
    assert_includes mail.html_part.body.to_s, "buying a gift for"
  end
end
