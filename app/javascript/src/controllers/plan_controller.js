import { Controller } from "stimulus"

import renderActivity from "../renderActivity"

export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit"]

  connect() {
    this.newActivityTargets.forEach(t => {
      $(t).autocomplete({
        source: this.autocompletions(t.getAttribute("data-benchmark-id")),
        open: () => $("ul.ui-menu").width($(t).innerWidth() + 5)
      })
    })
  }

  deleteActivity(e) {
    const { currentTarget } = e
    const activityToDelete = currentTarget.getAttribute("data-activity")
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")

    const newActivityList = this.activityMap[benchmarkId].filter(
      a => a.text !== activityToDelete
    )
    this.activityMapTarget.value = JSON.stringify({
      ...this.activityMap,
      [benchmarkId]: newActivityList
    })
    currentTarget.closest(".row").classList.add("d-none")
    $(this.newActivity(benchmarkId)).autocomplete({
      source: this.autocompletions(benchmarkId)
    })
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
          { text: currentTarget.value }
        ]
      })
      renderActivity(benchmarkId, currentTarget.value)
      $(currentTarget).autocomplete({
        source: this.autocompletions(benchmarkId)
      })
      e.target.value = ""
      e.preventDefault()
    }
  }

  autocompletions(benchmarkId) {
    return this.activities(benchmarkId).filter(
      a => this.currentActivities(benchmarkId).includes(a) === false
    )
  }

  currentActivities(benchmarkId) {
    return this.activityMap[benchmarkId].map(a => a.text)
  }

  activities(benchmarkId) {
    return JSON.parse(
      this.newActivity(benchmarkId).getAttribute("data-activities")
    )
  }

  newActivity(benchmarkId) {
    return this.newActivityTargets.find(
      t => t.getAttribute("data-benchmark-id") === benchmarkId
    )
  }

  get activityMap() {
    return JSON.parse(this.activityMapTarget.value)
  }
}
