import { Controller } from "@hotwired/stimulus"

// Stimulus controller to manage dynamic answer fields in the survey form
// Connects to data-controller="nested-form"
export default class extends Controller {
  static targets = ["container", "template"]

  // Add a new answer field by cloning the template
  add(event) {
    event.preventDefault()
    
    // Clone the template content
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  // Remove an answer field
  remove(event) {
    event.preventDefault()
    
    const item = event.target.closest(".nested-fields")
    
    // If the item has an id, mark it for destruction
    const destroyInput = item.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      item.style.display = "none"
    } else {
      // Otherwise, just remove it from the DOM
      item.remove()
    }
  }
}
