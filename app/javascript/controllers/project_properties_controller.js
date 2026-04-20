import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "propertyRow", "destroyField"]

  add() {
    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", Date.now().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    const row = event.target.closest("[data-project-properties-target='propertyRow']")
    const destroyField = row.querySelector("[data-project-properties-target='destroyField']")
    const idField = row.querySelector("input[name*='[id]']")

    if (idField && idField.value) {
      destroyField.value = "1"
      row.classList.add("hidden")
      return
    }

    row.remove()
  }
}
