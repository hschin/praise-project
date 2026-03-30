# S02: Auth Views

**Goal:** All Devise auth views render with Sanctuary Stone identity: centered card, atmospheric blur blobs, bottom-line inputs, gradient submit button
**Demo:** After this: After this: Sign in, sign up, forgot password, reset password, and account settings all render with centered card, atmospheric blur blobs, bottom-line inputs, and gradient submit button

## Tasks
- [x] **T01: All Devise auth views reskinned with centered card, atmospheric blur, bottom-line inputs, and gradient CTA** — Reskin sessions/new, registrations/new, registrations/edit, passwords/new, passwords/edit, confirmations/new, unlocks/new. Apply centered card with atmospheric blur blobs, bottom-line input pattern, gradient submit button. Delivered as part of the single M002 commit.
  - Estimate: 45m
  - Files: app/views/devise/sessions/new.html.erb, app/views/devise/registrations/new.html.erb, app/views/devise/registrations/edit.html.erb, app/views/devise/passwords/new.html.erb, app/views/devise/passwords/edit.html.erb, app/views/devise/confirmations/new.html.erb, app/views/devise/unlocks/new.html.erb, app/views/devise/shared/_links.html.erb
  - Verify: bin/rails test && echo PASS
