import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.toggleIcons()
  }

  close() {
    this.menuTarget.classList.add("hidden")
    if (this.hasOpenIconTarget) this.openIconTarget.classList.remove("hidden")
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.add("hidden")
  }

  toggleIcons() {
    if (!this.hasOpenIconTarget || !this.hasCloseIconTarget) return

    this.openIconTarget.classList.toggle("hidden")
    this.closeIconTarget.classList.toggle("hidden")
  }
}
