import { Controller } from "@hotwired/stimulus"

// Syncs a native color picker with a hex text input.
// The color picker is the authoritative value (submitted); the text input is
// a user-friendly alternative that drives the picker.
//
// Usage:
//   data-controller="color-picker"
//   data-color-picker-target="picker"   → <input type="color">
//   data-color-picker-target="hex"      → <input type="text"> (display + manual entry)

export default class extends Controller {
  static targets = ["picker", "hex"]

  connect() {
    // Initialise text field from picker's current value
    this.hexTarget.value = this.pickerTarget.value
  }

  pickerChanged() {
    this.hexTarget.value = this.pickerTarget.value
  }

  hexChanged() {
    const val = this.hexTarget.value.trim()
    if (/^#[0-9a-fA-F]{6}$/.test(val)) {
      this.pickerTarget.value = val
    }
  }
}
