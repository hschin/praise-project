import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator"]

  show() {
    this.indicatorTarget.classList.remove("opacity-0")
    this.indicatorTarget.classList.add("opacity-100")
    clearTimeout(this._timer)
    this._timer = setTimeout(() => {
      this.indicatorTarget.classList.remove("opacity-100")
      this.indicatorTarget.classList.add("opacity-0")
    }, 2000)
  }
}
