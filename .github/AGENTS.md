# Project: Simple Survey Tool

A Ruby on Rails 7.1 survey application using Hotwire (Turbo + Stimulus) for real-time interaction.  
Deployed via Capistrano to a single AWS EC2 instance (Ubuntu, Puma + systemd). Docker available for
containerised environments.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 7.1.2 |
| Frontend | Hotwire (Turbo Rails + Stimulus Rails), Importmap (no bundler) |
| Forms | SimpleForm |
| Pagination | will_paginate (~> 3.3) |
| Database | SQLite3 (development/test), MySQL2 (production) |
| Server | Puma |
| Testing | RSpec + Capybara + Selenium WebDriver |
| Deployment | Capistrano 3.20, rbenv (Ruby 3.2.1), Puma systemd |
| Containerisation | Docker (multi-stage, non-root rails user) |

---

## Domain Model

```
Survey
  question: string (required)
  has_many :answers, dependent: :destroy       # answer options
  has_many :survey_responses, dependent: :destroy
  accepts_nested_attributes_for :answers       # inline create/update/delete
  validates :question, presence: true
  validate :must_have_at_least_one_answer

Answer
  text: string (required)
  belongs_to :survey
  has_many :survey_responses, dependent: :destroy

SurveyResponse
  belongs_to :survey
  belongs_to :answer
  validates :answer_id, presence: true
```

`Survey` provides analytics helpers:
- `total_responses_count` — total responses for a survey
- `answer_counts` — hash of `Answer => count` (eager-loaded, no N+1)
- `answer_count(answer_id)` — count for a specific answer
- `answer_percentage(answer_id)` — percentage (0.0 when no responses)

**Deletion rule**: surveys with existing `survey_responses` cannot be deleted (enforced in view — delete button hidden; enforce in controller too if adding API routes).

---

## Routes

```
root → surveys#index

/surveys                             GET  surveys#index
/surveys/new                         GET  surveys#new
/surveys                             POST surveys#create
/surveys/:id/edit                    GET  surveys#edit
/surveys/:id                         PATCH/PUT surveys#update
/surveys/:id                         DELETE surveys#destroy

/surveys/:survey_id/survey_responses/new   GET  survey_responses#new
/surveys/:survey_id/survey_responses       POST survey_responses#create

/up                                  GET  rails/health#show
```

---

## Controllers

### SurveysController
- Pagination: 5 per page via `will_paginate`
- `new` / `edit` build one blank answer field if none present
- Strong params: `params.require(:survey).permit(:question, answers_attributes: [:id, :text, :_destroy])`

### SurveyResponsesController
- All actions respond with **Turbo Streams only** (`respond_to :turbo_stream`)
- `new` → renders `new.turbo_stream.erb` (replaces survey Turbo Frame with response form)
- `create` → on success: renders `update.turbo_stream.erb` (refreshes analytics); on failure: re-renders `new.turbo_stream.erb` with errors
- Strong params: `params.require(:survey_response).permit(:answer_id, :survey_id)`

---

## Views & Turbo Patterns

### Turbo Frames
- Each survey on the index page is wrapped in a Turbo Frame: `id="survey_<survey.id>"`
- The response form (`_form.html.erb`) targets the same frame ID, enabling in-place form swap
- Answer fields use individual frames: `id="answer_<object.id>"`

### Turbo Streams
- `new.turbo_stream.erb` — replaces `#survey_<id>` frame with the response form
- `update.turbo_stream.erb` — replaces `#survey_<id>` frame with refreshed analytics after submission

**Rule**: Never redirect from `SurveyResponsesController`; always render a Turbo Stream template.

### Stimulus Controllers
- **`nested-form`** (`app/javascript/controllers/nested_form_controller.js`):
  - `add()` — clones hidden `<template>` tag, replaces `__INDEX__` placeholder with `Date.now()`, inserts before target
  - `remove(event)` — for new (unsaved) records: removes from DOM; for persisted records: sets `_destroy=1` checkbox and hides
  - Data attributes: `data-nested-form-target="template|target"`, `data-new-record="true|false"`

---

## Database Conventions

- Foreign keys defined with `null: false` (enforced at DB level)
- Indexes on all foreign key columns
- Cascade deletes via `dependent: :destroy` in models AND `on_delete: :cascade` in migrations
- Migrations must be **reversible** — include a `def down` or use `reversible { |dir| dir.up { ... } }`
- Do not use `change_column` for column type changes in migrations — use `up`/`down` instead

---

## Forms

- Use **SimpleForm** (`simple_form_for`) everywhere, not `form_with` / `form_for`
- Wrappers: `:default` wrapper with `:input` class
- Errors rendered in `<span class="error">`, hints in `<span class="hint">`
- Nested fields built with `fields_for` inside `accepts_nested_attributes_for`
- The hidden `<template>` tag for dynamic fields must include `data-nested-form-target="template"`

---

## Testing

### Framework: RSpec + Capybara

- **Model specs** in `spec/models/` — test validations, associations, and business logic methods
- **System specs** in `spec/system/` — full browser tests via Selenium WebDriver; test Turbo Stream interactions end-to-end
- No request or controller specs currently; prefer system specs for controller-level coverage

### Conventions
- Use FactoryBot-style `create` / `build` helpers (via RSpec Rails) — no fixtures
- System specs drive a real browser; ensure `driven_by :selenium` is configured in `spec/rails_helper.rb`
- Test analytics: verify `total_responses_count`, `answer_count`, `answer_percentage` after creating fixtures

### Running Tests
```bash
bundle exec rspec                    # all specs
bundle exec rspec spec/models/       # model specs only
bundle exec rspec spec/system/       # system specs only
```

---

## Deployment

### Capistrano (primary — production on EC2)
- Config: `config/deploy.rb`, `config/deploy/production.rb`
- Server: `44.204.219.122` (AWS EC2), user `ubuntu`, SSH key `~/Downloads/vovan.pem`
- Deploy path: `/home/ubuntu/deployment_testing`
- Ruby version: **3.2.1** (managed by rbenv)
- Process manager: Puma via systemd
- Shared files (never overwritten): `config/database.yml`, `config/master.key`
- Shared dirs: `log`, `tmp/pids`, `tmp/sockets`, `storage`, `public/system`, `public/assets`
- Keeps last 5 releases

```bash
bundle exec cap production deploy          # deploy
bundle exec cap production deploy:rollback # rollback one release
```

### Docker (containerised environments)
- Multi-stage build: build stage installs gems + precompiles assets; final stage is lean runtime
- Entrypoint: `bin/docker-entrypoint` runs `rails db:prepare` before server start
- Non-root user `rails` (uid/gid set in Dockerfile)
- Exposes port 3000
- Production DB: MySQL2 (configure via `DATABASE_URL` or `config/database.yml`)

### Local Development
```bash
bin/dev           # starts Rails server via Procfile.dev
```

---

## Security Guidelines

- **Strong Parameters**: Always whitelist in the controller; never `permit!` and never pass raw params to models
- **Mass Assignment**: `answers_attributes` must explicitly list permitted keys (`[:id, :text, :_destroy]`)
- **No raw SQL**: Use ActiveRecord query interface; if raw SQL is needed, use parameterised queries (`sanitize_sql`)
- **Credentials**: Secrets live in `config/credentials.yml.enc` (encrypted); never commit plaintext secrets; `master.key` is in `.gitignore`
- **XSS**: Never use `html_safe`, `raw`, or `.html_safe` on user-supplied data
- **Authorisation**: Currently no authentication; if added, enforce in `ApplicationController` with a `before_action` and use `current_user` scoping on all queries
- **Delete guard**: Surveys with responses must not be deleteable — enforce in controller (`survey.survey_responses.exists?`), not only in view

---

## Code Conventions

- **Fat models, skinny controllers**: Business logic (analytics, validation) belongs in models
- **No callbacks for side-effects**: Avoid `after_create` / `after_save` for non-trivial logic; use service objects if needed
- **Eager loading**: Always use `includes` when iterating associations (see `answer_counts` for reference)
- **Helpers**: `ApplicationHelper` is available; prefer view helpers over logic in `.erb` files
- **Partials**: Extract repeated view logic to partials under the relevant resource folder
- **Naming**: Follow Rails conventions — snake_case for everything Ruby, kebab-case for Stimulus controller filenames

---

## Key Files Quick Reference

| Purpose | File |
|---|---|
| Survey model | `app/models/survey.rb` |
| Answer model | `app/models/answer.rb` |
| SurveyResponse model | `app/models/survey_response.rb` |
| Surveys controller | `app/controllers/surveys_controller.rb` |
| Survey responses controller | `app/controllers/survey_responses_controller.rb` |
| Routes | `config/routes.rb` |
| Database schema | `db/schema.rb` |
| Nested form JS | `app/javascript/controllers/nested_form_controller.js` |
| Survey index view | `app/views/surveys/index.html.erb` |
| Survey partial | `app/views/surveys/_survey.html.erb` |
| Response form | `app/views/survey_responses/_form.html.erb` |
| Turbo stream (new) | `app/views/survey_responses/new.turbo_stream.erb` |
| Turbo stream (update) | `app/views/survey_responses/update.turbo_stream.erb` |
| System spec | `spec/system/survey_tool_spec.rb` |
| Capistrano deploy | `config/deploy.rb` |
| Production server | `config/deploy/production.rb` |
| Docker entrypoint | `bin/docker-entrypoint` |
