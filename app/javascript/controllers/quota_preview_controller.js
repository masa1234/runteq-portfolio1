import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["examDate", "targetMinutes", "output", "quota"]

  update() {
    const examDate = new Date(`${this.examDateTarget.value}T00:00:00`)
    const targetMinutes = parseInt(this.targetMinutesTarget.value, 10)

    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const remainingDays = Math.ceil((examDate - today) / (1000 * 60 * 60 * 24))

    if (isNaN(examDate.getTime()) || isNaN(targetMinutes) || targetMinutes <= 0 || remainingDays <= 0) {
      this.outputTarget.hidden = true
      return
    }

    const dailyQuota = Math.ceil(targetMinutes / remainingDays)
    this.quotaTarget.textContent = dailyQuota
    this.outputTarget.hidden = false
  }
}
