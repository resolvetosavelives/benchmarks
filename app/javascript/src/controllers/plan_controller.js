import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["activityMap"]
  deleteActivity(e) {
    const { target } = e
    const activityToDelete = target.getAttribute("data-activity")
    const benchmarkId = target.getAttribute("data-benchmark-id")
    const newActivityList = this.activityMap[benchmarkId].filter(a => a !== activityToDelete)
    this.activityMapTarget.value = JSON.stringify({...this.activityMap, [benchmarkId]: newActivityList})
    target.closest("tr").classList.add("d-none")
  }

  get activityMap(){
    return JSON.parse(this.activityMapTarget.value)
  }
}
