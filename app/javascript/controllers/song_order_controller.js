import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

// Native HTML5 drag-and-drop for reordering song cards.
// Avoids nested-SortableJS event conflicts with the inner slide arrangement sortable.
//
// draggable="true" is NOT set in HTML — we arm it dynamically on pointerdown over
// the handle so that it doesn't interfere with SortableJS inside the same cards.
export default class extends Controller {
  static values = {
    url: String,
    param: { type: String, default: "order" },
    handle: { type: String, default: "[data-song-drag-handle]" }
  }

  connect() {
    this._dragged = null
    this._boundPointerdown = this._onPointerdown.bind(this)
    this._boundDragstart   = this._onDragstart.bind(this)
    this._boundDragover    = this._onDragover.bind(this)
    this._boundDrop        = this._onDrop.bind(this)
    this._boundDragend     = this._onDragend.bind(this)

    this.element.addEventListener("pointerdown", this._boundPointerdown)
    this.element.addEventListener("dragstart",   this._boundDragstart)
    this.element.addEventListener("dragover",    this._boundDragover)
    this.element.addEventListener("drop",        this._boundDrop)
    this.element.addEventListener("dragend",     this._boundDragend)
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this._boundPointerdown)
    this.element.removeEventListener("dragstart",   this._boundDragstart)
    this.element.removeEventListener("dragover",    this._boundDragover)
    this.element.removeEventListener("drop",        this._boundDrop)
    this.element.removeEventListener("dragend",     this._boundDragend)
    this._dragged = null
  }

  // Arm draggable only when the pointer goes down on the song-level handle.
  // We must only touch direct [data-id] children of this container — not nested
  // slide items (which also carry data-id) — to avoid arming native drag on the
  // wrong element when the user grabs a slide drag handle instead of a song handle.
  _onPointerdown(event) {
    const onHandle = !!event.target.closest(this.handleValue)

    // Walk up from the event target to find a direct [data-id] child of this element,
    // skipping any nested [data-id] elements (slide items inside song cards).
    let item = event.target.closest("[data-id]")
    while (item && item.parentElement !== this.element) {
      item = item.parentElement?.closest("[data-id]") ?? null
    }
    if (!item || item.parentElement !== this.element) return

    item.draggable = onHandle
  }

  _onDragstart(event) {
    // event.target is the draggable element (the card), not the original click target
    const item = event.target.closest("[data-id]")
    if (!item || !this.element.contains(item)) return

    this._dragged = item
    item.style.opacity = "0.4"
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", item.dataset.id)
  }

  _onDragover(event) {
    if (!this._dragged) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const target = event.target.closest("[data-id]")
    if (!target || target === this._dragged || !this.element.contains(target)) return

    const rect         = target.getBoundingClientRect()
    const insertBefore = event.clientY < rect.top + rect.height / 2

    // Skip redundant DOM moves
    if (insertBefore  && this._dragged.nextSibling === target) return
    if (!insertBefore && target.nextSibling === this._dragged) return

    this.element.insertBefore(
      this._dragged,
      insertBefore ? target : target.nextSibling
    )
  }

  _onDrop(event) {
    // Prevent the browser from navigating or reverting the drag
    event.preventDefault()
  }

  async _onDragend(event) {
    if (!this._dragged) return
    this._dragged.style.opacity = ""
    this._dragged.draggable = false
    const item    = this._dragged
    this._dragged = null
    await this._send(item)
  }

  async _send(item) {
    const id  = item.dataset.id
    const url = this.urlValue.replace(":id", id)
    const ids = Array.from(this.element.children)
      .filter(el => el.dataset.id)
      .map(el => parseInt(el.dataset.id, 10))
    await patch(url, {
      body: JSON.stringify({ [this.paramValue]: ids }),
      contentType: "application/json",
      responseKind: "turbo-stream"
    })
  }
}
