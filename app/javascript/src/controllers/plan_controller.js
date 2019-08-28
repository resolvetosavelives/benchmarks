import { Controller } from "stimulus"

import renderActivity from "../renderActivity"

export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit", "form"]

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
    this.validateActivityMap()
  }

  showNewActivity() {
    this.newActivityTarget.classList.remove("d-none")
  }

  addNewActivity(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    if (e.keyCode === 13 && currentTarget.value.length) {
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
      this.validateActivityMap()
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

  validateName() {
    if (this.formTarget.checkValidity() === false) {
      this.submitTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitTarget.removeAttribute("disabled")
    }
    this.formTarget.classList.add("was-validated")
  }

  validateActivityMap() {
    if (
      Object.keys(this.activityMap).every(
        key => this.activityMap[key].length === 0
      )
    ) {
      this.submitTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitTarget.removeAttribute("disabled")
    }
  }

  submit() {
    this.formTarget.submit()
  }

  get activityMap() {
    return JSON.parse(this.activityMapTarget.value)
  }
}
