import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minutesInput", "preset"]

  select({ params: { value } }) {
    this.minutesInputTarget.value = value
    this.presetTargets.forEach(btn => {
      const isActive = parseInt(btn.dataset.presetMinutesValueParam, 10) === value
      btn.classList.toggle("bg-blue-600", isActive)
      btn.classList.toggle("text-white", isActive)
      btn.classList.toggle("bg-gray-100", !isActive)
      btn.classList.toggle("text-gray-700", !isActive)
    })
  }
}
