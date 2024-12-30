import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="messages"
export default class extends Controller {
  static targets = ["container", "loadMoreButton"];
  connect() {
    console.log("messages controller connected 1")
    this.scrollToBottom();
  }

  scrollToBottom() {
    if (this.hasContainerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight;
    }
  }

  loadMore(event) {
    event.preventDefault(); // Prevent the default behavior of the button

    const url = this.loadMoreButtonTarget.getAttribute("href"); // Get the URL for the next page

    // Fetch the next page of messages
    fetch(url, { 
      headers: { 
        Accept: "text/vnd.turbo-stream.html" // Request a Turbo Stream response
      }
    })
      .then(response => response.text()) // Convert the response to plain text (Turbo Stream content)
      .then(html => {
        Turbo.renderStreamMessage(html); // Render the Turbo Stream response
      });
  }
}
