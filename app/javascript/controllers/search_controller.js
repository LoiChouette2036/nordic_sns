import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["results"];

  connect() {
    console.log("Search stimulus controller connected")
  }

  // trigger on keyup event in the search bar
  query(event) {
    const query = event.target.value.trim(); // Removes any leading or trailing whitespace from the string

    if (query === "") {
      this.clearResults();
      return;
    }

    // Send a GET request to the search endpoint with the query as a parameter
    fetch(`/users/search?query=${query}`, {
      headers: { Accept: "application/json" }, // Request JSON response
    })
      .then ((response) => {
        if (!response.ok) throw new Error("Network response was not ok");
        return response.json(); // Parse the JSON data
      })
      .then((data) => this.updateResults(data)) // Pass the data to the updateResults method
      .catch((error) => console.error("Error fetching search results:", error));
  }

  updateResults(users) {
    this.resultsTarget.innerHTML = ""; // Clear any existing results

    if (users.length === 0) {
      this.resultsTarget.style.display = "none";
      return;
    }

    // Iterate over the user data and create a list item for each user
    users.forEach((user) => {
      const listItem = document.createElement("li");
      listItem.className = "list-group-item d-flex justify-content-between align-items-center"; // Add Bootstrap styling for list items
      listItem.innerHTML = `
      <span>${user.name}</span>
      <button 
        class="btn btn-primary btn-sm"
        data-user-id="${user.id}"
        data-action="click->search#startConversation"
      >
        Start Conversation
      </button>
      `;
      this.resultsTarget.appendChild(listItem); // Append the <li> to the results ul
    });

    // Make the results list visible
    this.resultsTarget.style.display = "block";
  }

  // clear the search results and hides the results list
  clearResults() {
    this.resultsTarget.innerHTML = ""; // Clear the <ul> content
    this.resultsTarget.style.display = "none"; // Hide the <ul>
  }

  startConversation(event) {
    const userId = event.target.dataset.userId; // Get the user ID from the button's data attribute

    if (confirm("Do you want to start a conversation with this user?")) {
      // Send a POST request to create a conversation
      fetch("/conversations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        },
        body: JSON.stringify({ receiver_id: userId }),
      })
        .then((response) => {
          if (!response.ok) throw new Error("Failed to start conversation");
          return response.json();
        })
        .then((data) => {
          alert("Conversation request sent!");
          this.clearResults(); // Clear search results
        })
        .catch((error) => console.error("Error starting conversation:", error));
    }
  }
}
