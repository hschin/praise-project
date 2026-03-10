import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "button"]

  toggle() {
    this.containerTarget.classList.toggle("pinyin-hidden")
    const hidden = this.containerTarget.classList.contains("pinyin-hidden")
    this.buttonTarget.textContent = hidden ? "Show Pinyin" : "Hide Pinyin"
  }
}
