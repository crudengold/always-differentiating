// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
import "controllers"
import "bootstrap";

document.addEventListener("DOMContentLoaded", function(event) {
  // Your code to start up your application
});
