require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  test "should not save participant without required fields" do
    participant = Participant.new
    assert_not participant.save
  end

  test "should save participant with valid attributes" do
    event = events(:christmas_2024)
    user  = users(:alice)

    participant = Participant.new(
      event: event,
      user: user,
      name: "Jane Smith",
      email: "jane@example.com"
    )

    assert participant.save
  end

  test "should validate email format" do
    event = events(:christmas_2024)
    user  = users(:alice)

    participant = Participant.new(
      event: event,
      user: user,
      name: "Jane Smith",
      email: "invalid-email"
    )

    assert_not participant.save
  end

  test "should enforce unique email per event" do
    event = events(:christmas_2024)
    user  = users(:bob)
    alice = participants(:alice)

    duplicate = Participant.new(
      event: event,
      user: user,
      name: "Alice Duplicate",
      email: alice.email
    )

    assert_not duplicate.save
  end

  test "should allow same email in different events" do
    user = users(:alice)

    Participant.create!(
      event: events(:christmas_2024),
      user: user,
      name: "Jane Smith",
      email: "jane@example.com"
    )

    participant2 = Participant.new(
      event: events(:new_year_2025),
      user: user,
      name: "Jane Smith",
      email: "jane@example.com"
    )

    assert participant2.save
  end

  test "should return assigned participant" do
    alice = participants(:alice)
    bob   = participants(:bob)

    alice.update!(assigned_to: bob)

    assert_equal bob, alice.assigned_participant
  end

  test "fixture has associations" do
    alice = participants(:alice)

    assert_not_nil alice.event
    assert_not_nil alice.user
  end
end
