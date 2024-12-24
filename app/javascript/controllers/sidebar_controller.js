import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["content"];

  connect() {
    console.log("Sidebar controller connected")
  }

  show(event) {
    event.preventDefault();

    const postId = event.target.getAttribute("data-post-id");
    console.log(`Post ID: ${postId}`);

    // send to the show action and fetch the information to put it inside the html
    fetch(`/posts/${postId}`)
      .then(response => response.json())
      .then(data => {
        // inject the post details into the sidebar
        console.log("Content Target:", this.contentTarget);
        console.log("Post Data:", data); // Check if the data is correct
        
        this.contentTarget.innerHTML = `
          <h5>${data.user.email}</h5>
          <p>${data.content}</p>
          <p><small>Posted at ${new Date(data.created_at).toLocaleString()}</small></p>
        `;
      })
      .catch(error => console.error("Error fetching post:", error));
  }

}
