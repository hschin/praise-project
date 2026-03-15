import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values  = { url: String }

  edit() {
    this.displayTarget.hidden = true
    this.inputTarget.hidden   = false
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  async save() {
    const value = this.inputTarget.value.trim()
    if (!value) { this.cancel(); return }

    const token = document.querySelector("meta[name='csrf-token']").content
    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ deck: { title: value } })
    })

    this.displayTarget.textContent = value
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true
  }

  cancel() {
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true
    this.inputTarget.value    = this.displayTarget.textContent.trim()
  }
}
