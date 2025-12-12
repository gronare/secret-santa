require "test_helper"

class MagicLinkAuthenticationTest < ActionDispatch::IntegrationTest
  test "magic link signs in requested participant even when another session exists" do
    current_event = events(:christmas_2024)
    current_event.update!(status: :active)

    stale_event = events(:new_year_2025)
    stale_event.update!(status: :active)

    stale_participant = participants(:charlie) # belongs to stale_event
    stale_token = stale_participant.user.generate_token_for(:magic_link)

    # Seed session by visiting stale participant's magic link first
    get event_path(stale_event), params: { participant_id: stale_participant.id, magic_token: stale_token }
    assert_equal stale_participant.id, session[:participant_id]

    target_participant = participants(:bob)
    token = target_participant.user.generate_token_for(:magic_link)

    # Now visit a different event with a different participant; session should be replaced
    get event_path(current_event), params: { participant_id: target_participant.id, magic_token: token }

    assert_response :success
    assert_equal target_participant.id, session[:participant_id]
    assert_match current_event.name, response.body
  end
end
