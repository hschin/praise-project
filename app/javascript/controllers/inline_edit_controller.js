import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values  = {
    url:        String,
    field:      { type: String,  default: "title" },
    allowEmpty: { type: Boolean, default: false }
  }

  edit() {
    this.displayTarget.hidden = true
    this.inputTarget.hidden   = false
    this.inputTarget.focus()
    if (this.inputTarget.type !== "date") this.inputTarget.select()
  }

  async save() {
    const value = this.inputTarget.value.trim()
    if (!value && !this.allowEmptyValue) { this.cancel(); return }

    const token = document.querySelector("meta[name='csrf-token']").content
    const response = await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ deck: { [this.fieldValue]: value } })
    })

    if (this.inputTarget.type === "date" && value) {
      const d = new Date(value + "T00:00:00")
      this.displayTarget.textContent = d.toLocaleDateString("en-GB", {
        weekday: "long", day: "numeric", month: "long", year: "numeric"
      })
    } else {
      this.displayTarget.textContent = value || "Add notes…"
    }
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true

    if (response.ok) this.#flashSaved()
  }

  #flashSaved() {
    const el = document.createElement("span")
    el.textContent = "Saved"
    el.className = "text-xs text-emerald-600 font-body ml-2 transition-opacity duration-500"
    this.displayTarget.after(el)
    setTimeout(() => { el.style.opacity = "0" }, 1200)
    setTimeout(() => { el.remove() }, 1700)
  }

  cancel() {
    this.displayTarget.hidden = false
    this.inputTarget.hidden   = true
    if (this.inputTarget.type !== "date") {
      this.inputTarget.value = this.displayTarget.textContent.trim()
    }
  }
}
