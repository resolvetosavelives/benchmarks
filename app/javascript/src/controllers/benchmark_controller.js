import { Controller } from "stimulus"
import Hogan from "hogan.js"

export default class extends Controller {
  static targets = ["action", "addActionField", "confirm", "delete"]

  initialize() {
    this.childControllers = []
    this.parentController = this.application.controllers.find((controller) => {
      return controller.context.identifier === "plan"
    })
    this.parentController.childControllers.push(this)
    this.planPageDataModel = this.parentController.planPageDataModel
    this.planPageViewModel = this.parentController.planPageViewModel
  }

  connect() {
    this.deleteTarget.hidden = true
    this.indicatorId = Number(this.data.get("indicatorId"))
    this.indicatorDisplayAbbrev = Number(
      this.data.get("indicatorDisplayAbbrev")
    )
    this.barSegmentIndex = Number(this.data.get("barSegmentIndex"))
    this.initAutoCompleteForAddAction()
  }

  initAutoCompleteForAddAction() {
    const self = this // needed for nested callbacks which lose scope of "this"
    const excludedActions = this.planPageDataModel.getExcludedActionsForIndicator(
      this.indicatorId
    )
    if (this.hasAddActionFieldTarget) {
      $(this.addActionFieldTarget).autocomplete({
        appendTo: ".plan-container",
        minLength: 0, // this allows the down/up arrows to open the menu even without any chars entered, #171505810
        source: excludedActions.map((benchmarkAction) => {
          benchmarkAction.label = benchmarkAction.text
          benchmarkAction.value = benchmarkAction.text
          // this is the object that will be at ui.item in autocomplete.select()
          return benchmarkAction
        }),
        select: function (event, ui) {
          const benchmarkAction = ui.item
          self.addActionAndRender(benchmarkAction)
          self.initAutoCompleteForAddAction()
        },
      })
    }
  }

  addActionAndRender(benchmarkAction) {
    this.addActionId(benchmarkAction.id, this.barSegmentIndex)
    const templateData = {
      indicatorDisplayAbbrev: this.indicatorDisplayAbbrev,
      benchmarkActionId: benchmarkAction.id,
      benchmarkActionLevel: benchmarkAction.level,
      benchmarkActionText: benchmarkAction.text,
      barSegmentIndex: this.barSegmentIndex,
    }
    const actionRowTemplateSelector = this.data.get("actionRowTemplateSelector")
    const compiledTemplate = this.getTemplateFor(actionRowTemplateSelector)
    const renderedContent = compiledTemplate.render(templateData)
    $(renderedContent).insertBefore($(this.element).find(".action-form"))
    if (this.hasAddActionFieldTarget) {
      // NB: setTimeout is needed because without it the text field value does not
      // clear, probably due to real time/asynchronous UI stuff happening
      setTimeout(() => {
        this.addActionFieldTarget.value = ""
      }, 100)
    }
  }

  showAutocomplete() {
    if (this.hasAddActionFieldTarget) {
      $(this.addActionFieldTarget).autocomplete("search", " ")
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

  // Delete a benchmark indicator, which means deleting its child actions
  deleteActionsForIndicator() {
    const actionIds = this.planPageDataModel.getActionIdsForIndicator(
      this.indicatorId
    )
    actionIds.forEach((actionId) => {
      this.removeActionId(actionId, this.barSegmentIndex)
    })
    this.element.hidden = true
    const siblings = $(this.element).siblings(".benchmark-container:visible")
    if (siblings.length === 0) {
      this.element.parentElement.hidden = true
    }
  }

  addActionId(actionId, barSegmentIndex) {
    this.planPageDataModel.addActionById(actionId, barSegmentIndex)
    this.planPageViewModel.actionAdded(actionId, barSegmentIndex)
  }

  removeActionId(actionId, barSegmentIndex) {
    this.planPageDataModel.removeActionById(actionId, barSegmentIndex)
    this.planPageViewModel.actionRemoved(actionId, barSegmentIndex)
  }

  hasActions() {
    if (this.actionTargets.length > 0) {
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
