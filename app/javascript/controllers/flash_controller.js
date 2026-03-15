import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: false },
    delay:       { type: Number,  default: 4000 }
  }

  connect() {
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-x-full", "opacity-0")
    })
    if (this.autoDismissValue) {
      this._timer = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }

  dismiss() {
    clearTimeout(this._timer)
    this.element.classList.add("translate-x-full", "opacity-0")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }

  disconnect() {
    clearTimeout(this._timer)
  }
}
