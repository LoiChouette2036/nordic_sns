import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="load-more"
export default class extends Controller {
  connect() {
    // Bind the loadMore method to the current context
    this.loadMore = this.loadMore.bind(this)
    // Add a click event listener to the element this controller is attached to
    this.element.addEventListener("click", this.loadMore)
  }

  disconnect() {
    // Remove the previously bound click event listener
    this.element.removeEventListener("click", this.loadMore)
  }

  loadMore(event) {
    event.preventDefault()

    // Hide the "Load More" button to indicate loading is in progress
    this.element.style.display = "none"

    // Find the first <a> tag within the controller's element
    const link = this.element.querySelector("a")
    // Get the URL from the href attribute of the link
    const url = link.href

    // Perform a fetch request to the URL with Turbo Streams headers
    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => {
      if (response.ok) {
        // If the response is successful, return the response text
        return response.text()
      } else {
        // If the response is not successful, throw an error
        throw new Error("Network response was not ok")
      }
    })
    .then(html => {
      // Render the received turbo stream HTML to update the page
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      // Log any errors to the console for debugging
      console.error("Error loading more posts:", error)
      // Optionally, display a user-friendly error message
      alert("Failed to load more posts. Please try again later.")
      // Re-display the "Load More" button since loading failed
      this.element.style.display = 'block'
    })
  }

}
