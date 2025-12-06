require "test_helper"

module SecretSanta
  class AssignmentServiceTest < ActiveSupport::TestCase
    def setup
      event = events(:christmas_2024)
      @event = Event.includes(:participants).find(event.id)
    end

    test "raises error with fewer than 3 participants" do
      @event.participants.last.destroy
      @event = Event.includes(:participants).find(@event.id)

      assert_raises(AssignmentService::InsufficientParticipantsError) do
        AssignmentService.new(@event).call
      end
    end

    test "allows reshuffling assignments" do
      AssignmentService.new(@event).call
      first_assignments = @event.participants.pluck(:id, :assigned_to_id).to_h

      @event = Event.includes(:participants).find(@event.id)
      AssignmentService.new(@event).call
      second_assignments = @event.participants.pluck(:id, :assigned_to_id).to_h

      assert_equal first_assignments.keys.sort, second_assignments.keys.sort
    end

    test "assigns each participant to someone" do
      AssignmentService.new(@event).call

      @event.participants.each do |participant|
        assert_not_nil participant.assigned_to_id, "#{participant.name} should have an assignment"
      end
    end

    test "no one is assigned to themselves" do
      AssignmentService.new(@event).call

      @event.participants.each do |participant|
        assert_not_equal participant.id, participant.assigned_to_id,
          "#{participant.name} should not be assigned to themselves"
      end
    end

    test "creates a complete circle of assignments" do
      AssignmentService.new(@event).call

      # Follow the chain of assignments
      participant = @event.participants.first
      visited = Set.new

      @event.participants.count.times do
        assert_not visited.include?(participant.id), "Circular reference detected"
        visited.add(participant.id)
        participant = participant.assigned_participant
      end

      # Should visit all participants
      assert_equal @event.participants.count, visited.size
    end

    test "assignments are random" do
      event = Event.create!(
        name: "Test Event",
        organizer_name: "Test",
        organizer_email: "test@example.com"
      )

      10.times do |i|
        user = User.create!(
          email: "person#{i}@example.com"
        )

        event.participants.create!(
          user: user,
          name: "Person #{i}",
          email: user.email
        )
      end

      event = Event.includes(:participants).find(event.id)

      first_assignments = {}
      AssignmentService.new(event).call
      event.participants.each { |p| first_assignments[p.id] = p.assigned_to_id }

      event.participants.update_all(assigned_to_id: nil)
      event = Event.includes(:participants).find(event.id)
      AssignmentService.new(event).call

      second_assignments = {}
      event.participants.each { |p| second_assignments[p.id] = p.assigned_to_id }

      assert first_assignments != second_assignments,
        "Assignments should be randomized"
    end
  end
end
