import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "status"]

  start() {
    if (!this.hasSubmitTarget) return

    this.submitTarget.disabled = true
    this.submitTarget.dataset.originalLabel = this.submitTarget.value
    this.submitTarget.value = this.submitTarget.dataset.loadingText || "処理中..."

    if (this.hasStatusTarget) {
      this.statusTarget.classList.remove("hidden")
    }
  }
}
