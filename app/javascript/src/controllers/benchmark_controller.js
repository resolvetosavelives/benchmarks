import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["self", "confirm", "delete"]

  connect() {
    this.deleteTarget.hidden = true
  }

  confirm(e) {
    const { currentTarget } = e
    currentTarget.hidden = true
    this.deleteTarget.hidden = false
  }

  reset() {
    this.deleteTarget.hidden = true
    this.confirmTarget.hidden = false
  }

  delete(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    const activityMap = JSON.parse(this.activityMapTarget.value)
    delete activityMap[benchmarkId]
    this.activityMapTarget.value = JSON.stringify(activityMap)
    this.selfTarget.hidden = true
    const siblings = $(this.selfTarget).siblings(".benchmark-container:visible")
    if (siblings.length === 0) {
      this.selfTarget.parentElement.hidden = true
    }
  }

  get activityMapTarget() {
    return document.querySelector("#plan_activity_map")
  }
}
