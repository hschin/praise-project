---
estimated_steps: 28
estimated_files: 1
skills_used: []
---

# T02: Reskin nav bar with frosted glass, Newsreader wordmark, active indicators, and gradient CTA

Completely rewrite the <nav> block in application.html.erb to match the Sanctuary Stone design: frosted glass effect, Newsreader italic wordmark, active page detection with primary-colored text, Material Symbols mail icon, gradient New Deck button, and user email + logout. Also adjust flash container positioning if nav height changes.

This task covers requirements R010 (nav design) and R011 (frosted glass effect).

The target nav markup (adapted from Stitch deck_editor HTML for Rails ERB):

Steps:
1. In `app/views/layouts/application.html.erb`, replace the entire `<nav>` block (inside `unless devise_controller?`) with:
   ```erb
   <header class="bg-surface/80 backdrop-blur-xl flex justify-between items-center w-full px-8 h-16 sticky top-0 z-50 shadow-ambient">
     <div class="flex items-center gap-6">
       <%= link_to root_path, class: "text-2xl font-headline italic text-on-surface hover:opacity-80 transition-opacity" do %>
         Praise Project
       <% end %>
       <nav class="flex gap-6">
         <%= link_to "Decks", decks_path, class: "font-medium transition-colors duration-200 #{request.path.start_with?('/decks') ? 'text-primary border-b-2 border-primary pb-0.5' : 'text-on-surface-variant hover:text-primary'}" %>
         <%= link_to "Songs", songs_path, class: "font-medium transition-colors duration-200 #{request.path.start_with?('/songs') ? 'text-primary border-b-2 border-primary pb-0.5' : 'text-on-surface-variant hover:text-primary'}" %>
       </nav>
     </div>
     <div class="flex items-center gap-4">
       <span class="material-symbols-outlined text-on-surface-variant hover:bg-surface-container-highest p-2 rounded-full transition-colors cursor-pointer">mail</span>
       <%= button_to "New Deck", quick_create_decks_path, method: :post,
             class: "bg-gradient-to-r from-primary to-primary-container text-on-primary px-5 py-2 rounded-xl font-medium hover:opacity-90 transition-all active:scale-95 duration-150 cursor-pointer" %>
       <span class="text-sm text-on-surface-variant"><%= current_user.email %></span>
       <%= link_to "Logout", destroy_user_session_path, data: { turbo_method: :delete },
             class: "text-on-surface-variant font-medium hover:text-primary transition-colors" %>
     </div>
   </header>
   ```

2. Update the flash container `top-[80px]` to `top-[64px]` since the nav is now h-16 (64px) instead of variable py-4.

3. Verify the nav renders correctly by checking the ERB for key elements: frosted glass classes, Newsreader italic wordmark, gradient button, Material Symbols mail icon, active state detection.

## Inputs

- ``app/views/layouts/application.html.erb` — layout with token system and fonts from T01, still has old nav markup to be replaced`

## Expected Output

- ``app/views/layouts/application.html.erb` — nav rewritten with frosted glass header, Newsreader italic wordmark, active page indicators, gradient New Deck CTA, Material Symbols mail icon, adjusted flash container top offset`

## Verification

grep -q 'backdrop-blur' app/views/layouts/application.html.erb && grep -q 'font-headline italic' app/views/layouts/application.html.erb && grep -q 'from-primary to-primary-container' app/views/layouts/application.html.erb && grep -q 'material-symbols-outlined' app/views/layouts/application.html.erb && grep -q 'top-\[64px\]' app/views/layouts/application.html.erb && ! grep -q 'bg-stone-100 border-b' app/views/layouts/application.html.erb && echo 'PASS'
