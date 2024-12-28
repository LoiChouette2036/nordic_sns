import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails" // So we can call Turbo.renderStreamMessage

export default class extends Controller {
  static targets = ["status"]

  async accept(event) {
    event.preventDefault()
    const id = this.data.get("id")
    await this.updateStatus(id, "accepted")
  }

  async decline(event) {
    event.preventDefault()
    const id = this.data.get("id")
    await this.updateStatus(id, "declined")
  }

  async updateStatus(id, status) {
    const csrfToken = document.querySelector("[name='csrf-token']").content

    const response = await fetch(`/conversations/${id}`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html", 
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({ status })  // "status=accepted"
    })

    if (response.ok) {
      // Insert the <turbo-stream> into the DOM right away
      const turboStream = await response.text()
      Turbo.renderStreamMessage(turboStream)

      console.log(`Conversation ${status} successfully`, response)
    } else {
      console.error("Failed to update status", response)
    }
  }
}
