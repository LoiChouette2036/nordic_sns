import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// This file is specifically for Stimulus.js and is the entry point for Stimulus controllers.
// It initializes the Stimulus Application and enables features like debugging during development.
