import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "date", "content", "correctedSection", "correctedText", "feedbackSection", "feedback"]

  connect() {
    this.dialogTarget.addEventListener("close", this.onDialogClose)
  }

  disconnect() {
    this.dialogTarget.removeEventListener("close", this.onDialogClose)
  }

  onDialogClose = () => {
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    event.preventDefault()
    const payload = JSON.parse(event.currentTarget.dataset.diaryModalPayloadValue)

    this.dateTarget.textContent = payload.date
    this.contentTarget.textContent = payload.content || ""
    this.fillSection(this.correctedSectionTarget, this.correctedTextTarget, payload.corrected_text)
    this.fillSection(this.feedbackSectionTarget, this.feedbackTarget, payload.feedback)
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    event?.preventDefault()
    if (this.dialogTarget.open) {
      this.dialogTarget.close()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close(event)
    }
  }

  fillSection(section, textTarget, value) {
    const present = Boolean(value)
    textTarget.textContent = present ? value : ""
    section.hidden = !present
  }
}
