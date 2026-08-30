import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon", "toggleButton"]

  connect() {
    this.mediaQuery = window.matchMedia("(min-width: 768px)")
    this.boundCloseOnDesktop = this.closeOnDesktop.bind(this)
    this.mediaQuery.addEventListener("change", this.boundCloseOnDesktop)
    this.closeMenu()
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.boundCloseOnDesktop)
  }

  toggle() {
    if (this.isOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    if (!this.hasMenuTarget) return

    this.menuTarget.hidden = false
    this.syncUi(true)
  }

  closeMenu() {
    if (!this.hasMenuTarget) return

    this.menuTarget.hidden = true
    this.syncUi(false)
  }

  // Delay hiding so the link/button click can navigate or submit first.
  closeMenuFromItem() {
    setTimeout(() => this.closeMenu(), 0)
  }

  closeOnDesktop(event) {
    if (event.matches) this.closeMenu()
  }

  get isOpen() {
    return this.hasMenuTarget && !this.menuTarget.hidden
  }

  syncUi(isOpen) {
    if (this.hasOpenIconTarget) this.openIconTarget.hidden = isOpen
    if (this.hasCloseIconTarget) this.closeIconTarget.hidden = !isOpen
    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.setAttribute("aria-expanded", isOpen ? "true" : "false")
      this.toggleButtonTarget.setAttribute("aria-label", isOpen ? "メニューを閉じる" : "メニューを開く")
    }
  }
}
