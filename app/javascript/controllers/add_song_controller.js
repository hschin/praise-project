import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label", "spinner"]

  loading() {
    this.buttonTarget.disabled = true
    this.labelTarget.hidden = true
    this.spinnerTarget.hidden = false
  }
}
