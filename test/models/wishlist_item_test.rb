require "test_helper"

class WishlistItemTest < ActiveSupport::TestCase
  test "should not save without description" do
    participant = participants(:alice)
    item = WishlistItem.new(participant: participant)
    assert_not item.save
  end

  test "should save with valid attributes" do
    participant = participants(:alice)
    item = WishlistItem.new(
      participant: participant,
      description: "A nice book"
    )
    assert item.save
  end

  test "should save with optional url and priority" do
    participant = participants(:alice)
    item = WishlistItem.new(
      participant: participant,
      description: "A nice book",
      url: "https://example.com/book",
      priority: 5
    )
    assert item.save
    assert_equal "https://example.com/book", item.url
    assert_equal 5, item.priority
  end

  test "fixture has associations" do
    item = wishlist_items(:alice_book)
    assert_not_nil item.participant
    assert_equal participants(:alice), item.participant
    assert_equal "A nice fantasy book series", item.description
  end
end
