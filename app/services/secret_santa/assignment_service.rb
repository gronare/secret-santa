# HEY/Basecamp pattern: Service objects for complex business logic
# Handles the Secret Santa assignment algorithm
module SecretSanta
  class AssignmentService
    class InsufficientParticipantsError < StandardError; end

    def initialize(event)
      @event = event
      @participants = event.participants.to_a
    end

    def call
      validate!
      clear_existing_assignments!
      assign_participants!
      @event
    end

    private

    def validate!
      count = @event.participants.count
      raise InsufficientParticipantsError, "Need at least 3 participants" if count < 3
    end

    def clear_existing_assignments!
      return unless @event.assignments_drawn?

      @event.participants.update_all(assigned_to_id: nil)
      @participants.each { |p| p.assigned_to_id = nil }
    end

    def assign_participants!
      receivers = @participants.dup
      n = receivers.size

      receivers.shuffle!

      receivers.each_with_index do |receiver, i|
        if receiver.id == @participants[i].id
          swap_index = (i + 1) % n
          receivers[i], receivers[swap_index] = receivers[swap_index], receivers[i]
        end
      end

      @participants.each_with_index do |giver, i|
        giver.update_column(:assigned_to_id, receivers[i].id)
      end

      Rails.logger.info "[AssignmentService] Drew assignments for event #{@event.id}"
    end
  end
end
