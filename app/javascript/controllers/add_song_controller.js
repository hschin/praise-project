import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label", "spinner"]

  loading(event) {
    // Defer disabling until after the form submit event fires
    requestAnimationFrame(() => {
      this.buttonTarget.disabled = true
      this.labelTarget.hidden = true
      this.spinnerTarget.hidden = false
    })
  }
}
