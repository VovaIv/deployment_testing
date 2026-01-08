import { Controller } from "@hotwired/stimulus"

// Stimulus controller for dynamically adding and removing nested form fields
// Used for inline management of survey answer options
export default class extends Controller {
  static targets = ["container", "template", "item", "destroyField"]

  // Add a new answer field from the template
  add(event) {
    event.preventDefault()
    
    // Get the template content
    const content = this.templateTarget.content.cloneNode(true)
    
    // Replace NEW_RECORD with a unique identifier using random string + timestamp
    // This prevents collisions even with rapid additions
    const uniqueId = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const html = content.firstElementChild.outerHTML.replace(/NEW_RECORD/g, uniqueId)
    
    // Insert the new field into the container
    this.containerTarget.insertAdjacentHTML('beforeend', html)
  }

  // Remove an answer field
  remove(event) {
    event.preventDefault()
    
    const item = event.target.closest('[data-nested-form-target="item"]')
    const destroyField = item.querySelector('[data-nested-form-target="destroyField"]')
    
    if (destroyField && destroyField.value !== undefined) {
      // If this is an existing record (has an ID), mark it for destruction
      if (item.querySelector('input[name*="[id]"]')) {
        destroyField.value = '1'
        item.style.display = 'none'
      } else {
        // If this is a new record (no ID), just remove it from DOM
        item.remove()
      }
    } else {
      // Fallback: just remove the item
      item.remove()
    }
  }
}
