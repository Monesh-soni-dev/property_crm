import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle(event) {
    const section = event.currentTarget.closest("section")
    const panel = section.querySelector("[data-material-breakdown-target='panel']")
    panel.classList.toggle("hidden")
  }
}