import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit"]

  deleteActivity(e) {
    const { target } = e
    const activityToDelete = target.getAttribute("data-activity")
    const benchmarkId = target.getAttribute("data-benchmark-id")
    const newActivityList = this.activityMap[benchmarkId].filter(a => a !== activityToDelete)
    this.activityMapTarget.value = JSON.stringify({...this.activityMap, [benchmarkId]: newActivityList})
    target.closest("tr").classList.add("d-none")
  }

  showNewActivity() {
    this.newActivityTarget.classList.remove("d-none")
  }

  addNewActivity(e) {
    if (e.keyCode === 13) {
      this.activityMapTarget.value = JSON.stringify({...this.activityMap, other: [...(this.activityMap.other || []), e.target.value]})
      e.target.value = ""
      this.submitTarget.click()
      e.preventDefault()
    }
  }

  get activityMap(){
    return JSON.parse(this.activityMapTarget.value)
  }
}
