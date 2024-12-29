import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message-form"
export default class extends Controller {
  static targets = ["input"]

  reset() {
    this.inputTarget.value = "";
  }
}
