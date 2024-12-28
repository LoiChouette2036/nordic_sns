// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

// This is the main entry point for your JavaScript code in Rails 7+ with importmap or Webpacker.
// It handles the overall application-level imports and setups like:
// Importing Turbo for page transitions.
// Importing controllers from Stimulus.
// Loading libraries like Bootstrap.

// Initialize ActionCable
import { createConsumer } from "@rails/actioncable";
window.App ||= {};
App.cable = createConsumer();