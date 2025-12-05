import { Controller } from "@hotwired/stimulus"

// Manages draft event state in sessionStorage
// Redirects users back to their in-progress event
export default class extends Controller {
  static values = {
    slug: String,
    action: String // "save" or "clear"
  }

  connect() {
    if (this.actionValue === "save" && this.slugValue) {
      // Save event slug when organizer creates event
      sessionStorage.setItem("draft_event_slug", this.slugValue)
    } else if (this.actionValue === "clear") {
      // Clear draft when explicitly requested
      sessionStorage.removeItem("draft_event_slug")
    } else {
      // Check for draft event and redirect if found
      this.checkForDraft()
    }
  }

  checkForDraft() {
    const draftSlug = sessionStorage.getItem("draft_event_slug")
    if (draftSlug) {
      // Redirect to organize page using Turbo
      Turbo.visit(`/events/${draftSlug}/organize`)
    }
  }

  clear(event) {
    if (event) {
      event.preventDefault()

      if (!confirm("This will clear your current draft and start a new event. Continue?")) {
        return
      }
    }

    sessionStorage.removeItem("draft_event_slug")
    // Navigate using Turbo
    Turbo.visit("/events/new")
  }
}
