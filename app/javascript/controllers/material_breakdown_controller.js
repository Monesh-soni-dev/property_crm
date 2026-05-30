import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "chevron", "content"]

  toggle(event) {
    const button = event.currentTarget
    const content = button.nextElementSibling
    const chevron = button.querySelector('[data-material-breakdown-target="chevron"]')

    if (content.style.display === "none") {
      content.style.display = ""
      if (chevron) chevron.style.transform = "rotate(0deg)"
    } else {
      content.style.display = "none"
      if (chevron) chevron.style.transform = "rotate(-90deg)"
    }
  }

  collapseAll() {
    this.contentTargets.forEach(content => {
      content.style.display = "none"
    })
    this.chevronTargets.forEach(chevron => {
      chevron.style.transform = "rotate(-90deg)"
    })
  }

  expandAll() {
    this.contentTargets.forEach(content => {
      content.style.display = ""
    })
    this.chevronTargets.forEach(chevron => {
      chevron.style.transform = "rotate(0deg)"
    })
  }
}
