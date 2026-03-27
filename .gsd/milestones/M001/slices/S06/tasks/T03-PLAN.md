# T03: 06-global-components 03

**Slice:** S06 — **Milestone:** M001

## Description

Update error copy strings across three surfaces: the PPTX export job (three broadcast_error call sites), the export button error state partial, and the import failed partial. Replaces generic/inconsistent error messages with specific, actionable copy per the locked user decisions.

Purpose: FORM-03 — Import and export error messages include a clear description of what went wrong and a specific next step.
Output: Updated generate_pptx_job.rb, _export_button.html.erb, _failed.html.erb.

## Must-Haves

- [ ] "All three generate_pptx_job.rb broadcast_error call sites pass the string 'Export failed — click to try again.' consistently"
- [ ] "The export button error state copy reads 'Export failed — click to try again.' in the rendered partial"
- [ ] "The import failed partial h3 reads 'Couldn't find lyrics for \"[Title]\". Try pasting them manually below.' — with song title interpolated"
- [ ] "The import failed partial uses the exclamation-triangle Heroicons SVG instead of the bare ✗ character"

## Files

- `test/controllers/songs_controller_test.rb`
- `app/jobs/generate_pptx_job.rb`
- `app/views/decks/_export_button.html.erb`
- `app/views/songs/_failed.html.erb`
