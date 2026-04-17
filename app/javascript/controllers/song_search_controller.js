import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item", "empty", "importSection", "importTitle", "pastePath"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    let visible = 0

    this.itemTargets.forEach(item => {
      const match = query === "" ||
        item.dataset.title.toLowerCase().includes(query) ||
        (item.dataset.englishTitle || "").toLowerCase().includes(query) ||
        (item.dataset.artist || "").toLowerCase().includes(query)
      item.hidden = !match
      if (match) visible++
    })

    const noMatches = visible === 0 && query !== ""

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = !noMatches
    }

    if (this.hasImportSectionTarget) {
      this.importSectionTarget.hidden = !noMatches
      if (noMatches) {
        this.importTitleTargets.forEach(el => { el.value = this.inputTarget.value.trim() })
      }
    }

    if (this.hasImportTitleTarget) {
      this.importTitleTargets.forEach(el => { el.value = this.inputTarget.value.trim() })
    }

    if (this.hasPastePathTarget) {
      const title = this.inputTarget.value.trim()
      const base = this.pastePathTarget.dataset.basePath || this.pastePathTarget.href.split("?")[0]
      this.pastePathTarget.dataset.basePath = base
      this.pastePathTarget.href = title ? `${base}?title=${encodeURIComponent(title)}` : base
    }
  }
}
