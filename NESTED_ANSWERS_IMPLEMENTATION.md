# Survey with Nested Answers - Implementation Notes

## Overview
This implementation allows surveys to manage multiple answer options inline using Hotwire (Turbo + Stimulus).

## Key Components

### Models
- **Survey**: Has many answers, accepts nested attributes with `allow_destroy: true`
- **Answer**: Belongs to survey, validates presence of text

### Controller (SurveysController)
- `new` action: Pre-builds 3 empty answer fields for the form
- `edit` action: Ensures at least one answer field is available
- `create/update` actions: Accept nested `answers_attributes` parameter
- Strong params accept: `:id`, `:text`, `:_destroy` for each answer

### Views
- **_form.html.erb**: Main survey form with nested answer fields
  - Uses `data-controller="nested-form"` for Stimulus
  - Renders answer fields using `simple_fields_for :answers`
  - Includes a hidden template for new answer fields
  - "Add Answer Option" button triggers Stimulus to add fields
  
- **_answer_fields.html.erb**: Partial for each answer field
  - Text input for answer option
  - Hidden `_destroy` field for marking deletion
  - "Remove" button to remove/mark answer for deletion

### JavaScript (nested_form_controller.js)
- **add()**: Clones the template and adds a new answer field
  - Replaces `NEW_RECORD` placeholder with timestamp for unique IDs
- **remove()**: Hides existing records (marks for destruction) or removes new fields from DOM

## Usage
1. Create/Edit Survey: Fill in question and add multiple answer options
2. Add answers: Click "Add Answer Option" button
3. Remove answers: Click "Remove" button next to any answer field
4. Existing answers are marked for deletion (not immediately removed from DB)
5. New unsaved answers are removed from the DOM immediately

## Testing
- Model specs test nested attribute acceptance and destruction
- System specs test creating and editing surveys with answers
