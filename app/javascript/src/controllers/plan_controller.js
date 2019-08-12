import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit"]

  deleteActivity(e) {
    const { currentTarget } = e
    const activityToDelete = currentTarget.getAttribute("data-activity")
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")

    const newActivityList = this.activityMap[benchmarkId].filter(
      a => a !== activityToDelete
    )
    this.activityMapTarget.value = JSON.stringify({
      ...this.activityMap,
      [benchmarkId]: newActivityList
    })
    currentTarget.closest(".row").classList.add("d-none")
  }

  showNewActivity() {
    this.newActivityTarget.classList.remove("d-none")
  }

  addNewActivity(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    if (e.keyCode === 13) {
      this.activityMapTarget.value = JSON.stringify({
        ...this.activityMap,
        [benchmarkId]: [
          ...(this.activityMap[benchmarkId] || []),
          currentTarget.value
        ]
      })
      e.target.value = ""
      this.submitTarget.click()
      e.preventDefault()
    }
  }

  get activityMap() {
    return JSON.parse(this.activityMapTarget.value)
  }
}
