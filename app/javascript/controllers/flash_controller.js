import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dismiss: { type: Number, default: 5000 }
  }

  connect() {
    if (this.dismissValue > 0) {
      this.timeout = window.setTimeout(() => this.dismiss(), this.dismissValue)
    }
  }

  disconnect() {
    window.clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.remove()
  }
}
