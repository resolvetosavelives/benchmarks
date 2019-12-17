import { Controller } from "stimulus"
import Hogan from "hogan.js"

// TODO: test coverage for recent changes

export default class extends Controller {
  static targets = ["activity", "addActivityField", "confirm", "delete"]

  initialize() {
    this.childControllers = []
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "plan";                                                                           
    });
    this.parentController.childControllers.push(this)
  }

  connect() {
    this.deleteTarget.hidden = true
    this.benchmarkIndicatorId = this.data.get("indicator-id")
    this.benchmarkAbbreviation = this.data.get("indicator-abbreviation")
    this.initAutoCompleteForAddActivity()
  }

  initAutoCompleteForAddActivity() {
    const self = this  // needed for nested callbacks which lose scope of "this"
    const excludedActivities = JSON.parse(this.data.get("excluded-activities"))
    if (this.hasAddActivityFieldTarget) {
      $(this.addActivityFieldTarget).autocomplete({
        appendTo: ".plan-container",
        source: excludedActivities.map((benchmarkActivity) => {
          benchmarkActivity.label = benchmarkActivity.text
          benchmarkActivity.value = benchmarkActivity.text
          // this is the object that will be at ui.item in autocomplete.select()
          return benchmarkActivity
        }),
        select: function(event, ui) {
          const benchmarkActivity = ui.item
          self.addActivityAndRender(benchmarkActivity)
        }
      })
    }
  }

  addActivityAndRender(benchmarkActivity) {
    this.addActivityId(benchmarkActivity.id)
    const templateData = {
      benchmarkActivityId: benchmarkActivity.id,
      displayAbbreviation: this.benchmarkAbbreviation,
      benchmarkActivityLevel: benchmarkActivity.level,
      benchmarkActivityText: benchmarkActivity.text,
    }
    const activityRowTemplateSelector = this.data.get("activityRowTemplateSelector")
    const compiledTemplate = this.getTemplateFor(activityRowTemplateSelector)
    const renderedContent = compiledTemplate.render(templateData)
    $(renderedContent).insertBefore($(this.element).find(".activity-form"))
    if (this.hasAddActivityFieldTarget) {
      // NB: setTimeout is needed because without it the text field value does not
      // clear, probably due to real time/asynchronous UI stuff happening
      setTimeout(() => {
        this.addActivityFieldTarget.value = ""
      }, 100)
    }
  }

  showAutocomplete() {
    if (this.hasAddActivityFieldTarget) {
      $(this.addActivityFieldTarget).autocomplete("search", " ")
    }
  }

  /* The first step in the deletion process. This will hide the current target
   * (which is the initially visible delete button) and show the "Really
   * Delete" button. */
  confirm(e) {
    const { currentTarget } = e
    currentTarget.hidden = true
    this.deleteTarget.hidden = false
  }

  /* Reset the state of the workflow by hiding the "Really Delete" button and
   * revealing the inital delete button. */
  reset() {
    this.deleteTarget.hidden = true
    this.confirmTarget.hidden = false
  }

  // Delete a benchmark indicator, which means deleting its child activities
  deleteActivitiesForIndicator(e) {
    const { currentTarget } = e
    const activityIds = JSON.parse(this.data.get("activityIds"))
    activityIds.forEach((activityId) => {
      this.removeActivityId(activityId)
    })
    this.element.hidden = true
    const siblings = $(this.element).siblings(".benchmark-container:visible")
    if (siblings.length === 0) {
      this.element.parentElement.hidden = true
    }
  }

  addActivityId(activityId) {
    this.parentController.addActivityId(activityId)
  }

  removeActivityId(activityId) {
    this.parentController.removeActivityId(activityId)
  }

  hasActivities() {
    if (this.activityTargets.length > 0) {
      return true
    }
    return false
  }

  // returns a String of template content ready for data/context
  getTemplateFor(jqSelector) {
    const templateHtml = $(jqSelector).html()
    return Hogan.compile(templateHtml)
  }
}
