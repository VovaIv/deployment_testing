// Stimulus controller for managing dynamic answer fields in survey form
// Handles adding and removing answer fields inline using Hotwire
//
// Usage in view:
//   <div data-controller="nested-form">
//     <!-- Template for new answer fields -->
//     <template data-nested-form-target="template">
//       <%= fields for nested answer %>
//     </template>
//     
//     <!-- Container for answer fields -->
//     <div data-nested-form-target="container">
//       <%= existing answer fields %>
//     </div>
//     
//     <!-- Button to add new field -->
//     <button data-action="click->nested-form#add">Add Answer</button>
//   </div>

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  // Add a new answer field by cloning the template
  add(event) {
    event.preventDefault()
    
    // Clone the template content
    const content = this.templateTarget.content.cloneNode(true)
    
    // Replace the template's index placeholder with a unique timestamp
    // This ensures each new field has a unique name attribute
    const uniqueId = new Date().getTime()
    const html = content.querySelector("div").outerHTML.replace(/NEW_RECORD/g, uniqueId)
    
    // Insert the new field at the end of the container
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  // Remove an answer field by marking it for destruction
  // The _destroy field tells Rails to delete this record on save
  remove(event) {
    event.preventDefault()
    
    const fieldset = event.target.closest(".nested-fields")
    
    // If the answer is persisted (has an id), mark it for destruction
    const destroyField = fieldset.querySelector("input[name*='_destroy']")
    if (destroyField) {
      destroyField.value = "1"
      fieldset.style.display = "none"
    } else {
      // If not persisted, just remove the field from the DOM
      fieldset.remove()
    }
  }
}
