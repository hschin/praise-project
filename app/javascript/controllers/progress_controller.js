import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]
  static values = { 
    duration: { type: Number, default: 8000 },
    start: { type: Number, default: 0 },
    end: { type: Number, default: 90 }
  }

  connect() {
    this.animateProgress()
  }

  animateProgress() {
    const startWidth = this.startValue
    const endWidth = this.endValue
    const duration = this.durationValue
    const startTime = Date.now()

    const animate = () => {
      const elapsed = Date.now() - startTime
      const progress = Math.min(elapsed / duration, 1)
      
      // Ease-out curve for more natural feel
      const eased = 1 - Math.pow(1 - progress, 3)
      const currentWidth = startWidth + (endWidth - startWidth) * eased
      
      this.barTarget.style.width = `${currentWidth}%`
      
      if (progress < 1) {
        requestAnimationFrame(animate)
      }
    }

    requestAnimationFrame(animate)
  }
}
