import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from "@rails/request.js"

export default class extends Controller {
  static values = {
    url: String,
    param: { type: String, default: "position" }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-drag-handle]",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  async onEnd(event) {
    if (event.oldIndex === event.newIndex) return

    const id = event.item.dataset.id
    const url = this.urlValue.replace(":id", id)

    let body
    if (this.paramValue === "arrangement" || this.paramValue === "order") {
      const ids = Array.from(this.element.children).map(el => parseInt(el.dataset.id, 10))
      body = JSON.stringify({ [this.paramValue]: ids })
    } else {
      body = JSON.stringify({ [this.paramValue]: event.newIndex + 1 })
    }

    await patch(url, {
      body,
      contentType: "application/json",
      responseKind: "turbo-stream"
    })
  }
}
