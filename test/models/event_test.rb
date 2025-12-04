require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should not save event without required fields" do
    event = Event.new
    assert_not event.save, "Saved the event without required fields"
  end

  test "should save event with valid attributes" do
    event = Event.new(
      name: "Family Christmas 2024",
      organizer_name: "John Doe",
      organizer_email: "john@example.com"
    )
    assert event.save, "Could not save event with valid attributes"
  end

  test "should generate slug on creation" do
    event = Event.create!(
      name: "Family Christmas 2025",
      organizer_name: "John Doe",
      organizer_email: "john@example.com"
    )
    assert_not_nil event.slug
    assert event.slug.length > 0
  end

  test "should require unique slug" do
    event = events(:christmas_2024)
    event2 = Event.new(
      name: "Event 2",
      organizer_name: "Jane Doe",
      organizer_email: "jane@example.com",
      slug: event.slug
    )
    assert_not event2.save
  end

  test "should validate email format" do
    event = Event.new(
      name: "Test Event",
      organizer_name: "Test User",
      organizer_email: "invalid-email"
    )
    assert_not event.save
  end

  test "should use slug as param" do
    event = events(:christmas_2024)
    assert_equal event.slug, event.to_param
  end

  test "fixture event has associations" do
    event = events(:christmas_2024)
    assert_equal 2, event.participants.count
  end
end
