import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from "@rails/request.js"

export default class extends Controller {
  static values = {
    url: String,
    param: { type: String, default: "position" },
    handle: { type: String, default: "[data-drag-handle]" },
    group: { type: String, default: "" }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: this.handleValue,
      group: { name: this.groupValue || null, pull: false, put: false },
      // Force pointer-event fallback so native drag events (and the draggable
      // attribute) cannot interfere — required when nested inside elements that
      // use HTML5 drag-and-drop (e.g. the song-order controller).
      forceFallback: true,
      onStart: this.onStart.bind(this),
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
    this._removeFallbackListeners?.()
  }

  onStart(event) {
    this._handled = false
    this._item = event.item

    // Disable nested slide sortables so they can't steal Sortable.active
    if (this.paramValue === "order") {
      this._eachInnerSortable(s => s.option("disabled", true))
    }

    // Fallback: if onEnd never fires (nested-sortable SortableJS bug),
    // catch pointerup and wait until Sortable.active is null before reading
    // the DOM — that's the signal that _onDrop has fully settled.
    const onUp = () => {
      this._waitUntilDropComplete(() => {
        if (this._handled) return
        this._handled = true
        if (this.paramValue === "order") this._eachInnerSortable(s => s.option("disabled", false))
        this._send(this._item)
      })
    }
    document.addEventListener("pointerup", onUp, { once: true })
    document.addEventListener("touchend", onUp, { once: true })
    this._removeFallbackListeners = () => {
      document.removeEventListener("pointerup", onUp)
      document.removeEventListener("touchend", onUp)
    }
  }

  async onEnd(event) {
    this._handled = true
    this._removeFallbackListeners?.()
    if (this.paramValue === "order") this._eachInnerSortable(s => s.option("disabled", false))
    if (event.oldIndex === event.newIndex) return
    await this._send(event.item)
  }

  async _send(item) {
    const id = item.dataset.id
    const url = this.urlValue.replace(":id", id)
    const ids = Array.from(this.element.children).map(el => parseInt(el.dataset.id, 10))
    await patch(url, {
      body: JSON.stringify({ [this.paramValue]: ids }),
      contentType: "application/json",
      responseKind: "turbo-stream"
    })
  }

  // Poll until SortableJS has cleared its active instance (drop is fully done)
  _waitUntilDropComplete(callback) {
    if (Sortable.active) {
      requestAnimationFrame(() => this._waitUntilDropComplete(callback))
    } else {
      callback()
    }
  }

  _eachInnerSortable(fn) {
    this.element.querySelectorAll("[data-sortable-param-value='arrangement']").forEach(el => {
      const instance = Sortable.get(el)
      if (instance) fn(instance)
    })
  }
}
