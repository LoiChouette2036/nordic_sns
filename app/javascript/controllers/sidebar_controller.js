import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["content", "commentsList"];

  connect() {
    console.log("Sidebar controller connected")
  }

  show(event) {
    event.preventDefault();

    const postId = event.target.getAttribute("data-post-id");
    this.currentPostId = postId; // if we want to use it on a\others action from thhs controller, we put it on a gobal variable it seems
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

        // Populate the hidden input with the parent_post_id
        const parentPostIdInput = this.element.querySelector('input[name="post[parent_post_id]"]');
        if (parentPostIdInput) {
          parentPostIdInput.value = postId; // Set the parent_post_id to the current post ID
        }

        // Display the comments
        this.commentsListTarget.innerHTML = ""; // Clear existing comments
        data.replies.forEach(reply => {
          const commentElement = document.createElement("div");
          commentElement.classList.add("comment");
          commentElement.innerHTML = `
          <p><strong>${reply.user.email}</strong>: ${reply.content}</p>
          <p><small>Posted at ${new Date(reply.created_at).toLocaleString()}</small></p>
        `;
        this.commentsListTarget.appendChild(commentElement);
        });
      })
      .catch(error => console.error("Error fetching post:", error));
  }
}
