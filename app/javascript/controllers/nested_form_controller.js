import { Controller } from "@hotwired/stimulus"

// Stimulus controller for dynamically adding and removing nested form fields
// Updated to use the turbo_frame_tag pattern
export default class extends Controller {
  static targets = ["target", "template"]

  add() {
    // Clone the template content and replace the "__INDEX__" placeholder with a unique ID
    const content = this.templateTarget.innerHTML.replace(/__INDEX__/g, new Date().getTime())
    this.targetTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    // Find the closest parent element marked for destruction and hide/remove it
    const wrapper = event.target.closest(".answer-field") || event.target.closest("turbo-frame")

    if (wrapper.dataset.newRecord == "true") {
      // If it's a new, unsaved record, just remove from the DOM
      wrapper.remove()
    } else {
      // For existing records, set the `_destroy` field and hide it
      const destroyField = wrapper.querySelector("input[name*='_destroy']")
      if (destroyField) {
        destroyField.value = "1"
        wrapper.style.display = 'none'
      }
    }
  }
}
