import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item", "empty"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    let visible = 0

    this.itemTargets.forEach(item => {
      const match = query === "" || item.dataset.title.toLowerCase().includes(query)
      item.hidden = !match
      if (match) visible++
    })

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = visible > 0 || query === ""
    }
  }
}
