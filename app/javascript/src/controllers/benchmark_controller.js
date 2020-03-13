import { Controller } from "stimulus"
import Hogan from "hogan.js"

export default class extends Controller {
  static targets = ["activity", "addActivityField", "confirm", "delete"]

  initialize() {
    this.childControllers = []
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "plan";                                                                           
    });
    this.parentController.childControllers.push(this)
    this.planPageDataModel = this.parentController.planPageDataModel
    this.planPageViewModel = this.parentController.planPageViewModel
  }

  connect() {
    this.deleteTarget.hidden = true
    this.indicatorId = Number(this.data.get("indicatorId"))
    this.indicatorDisplayAbbrev = Number(this.data.get("indicatorDisplayAbbrev"))
    this.barSegmentIndex = Number(this.data.get("barSegmentIndex"))
    this.initAutoCompleteForAddActivity()
  }

  initAutoCompleteForAddActivity() {
    const self = this  // needed for nested callbacks which lose scope of "this"
    const excludedActivities = this.planPageDataModel.getExcludedActivitiesForIndicator(this.indicatorId)
    if (this.hasAddActivityFieldTarget) {
      $(this.addActivityFieldTarget).autocomplete({
        appendTo: ".plan-container",
        minLength: 0, // this allows the down/up arrows to open the menu even without any chars entered, #171505810
        source: excludedActivities.map((benchmarkActivity) => {
          benchmarkActivity.label = benchmarkActivity.text
          benchmarkActivity.value = benchmarkActivity.text
          // this is the object that will be at ui.item in autocomplete.select()
          return benchmarkActivity
        }),
        select: function(event, ui) {
          const benchmarkActivity = ui.item
          self.addActivityAndRender(benchmarkActivity)
          self.initAutoCompleteForAddActivity()
        }
      })
    }
  }

  addActivityAndRender(benchmarkActivity) {
    this.addActivityId(benchmarkActivity.id, this.barSegmentIndex)
    const templateData = {
      indicatorDisplayAbbrev: this.indicatorDisplayAbbrev,
      benchmarkActivityId: benchmarkActivity.id,
      benchmarkActivityLevel: benchmarkActivity.level,
      benchmarkActivityText: benchmarkActivity.text,
      barSegmentIndex: this.barSegmentIndex
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
    const activityIds = this.planPageDataModel.getActivityIdsForIndicator(this.indicatorId)
    activityIds.forEach((activityId) => {
      this.removeActivityId(activityId, this.barSegmentIndex)
    })
    const { currentTarget } = e
    this.element.hidden = true
    const siblings = $(this.element).siblings(".benchmark-container:visible")
    if (siblings.length === 0) {
      this.element.parentElement.hidden = true
    }
  }

  addActivityId(activityId, barSegmentIndex) {
    this.planPageDataModel.addActivityById(activityId, barSegmentIndex)
    this.planPageViewModel.activityAdded(activityId, barSegmentIndex)
  }

  removeActivityId(activityId, barSegmentIndex) {
    this.planPageDataModel.removeActivityById(activityId, barSegmentIndex)
    this.planPageViewModel.activityRemoved(activityId, barSegmentIndex)
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
