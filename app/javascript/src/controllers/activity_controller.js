import { Controller } from "stimulus"

export default class extends Controller {

  initialize() {
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "benchmark";
    });
    this.parentController.childControllers.push(this)
    this.planPageDataModel = this.parentController.planPageDataModel
    this.planPageViewModel = this.parentController.planPageViewModel
  }

  connect() {
    this.id = Number(this.data.get("id"))
    this.barSegmentIndex = Number(this.data.get("barSegmentIndex"))
  }

  deleteSelf(e) {
    const { currentTarget } = e
    this.removeActivityId(this.id, this.barSegmentIndex)
    $(currentTarget.closest(".row")).remove()
  }

  removeActivityId(activityId, barSegmentIndex) {
    this.planPageDataModel.removeActivityById(activityId, barSegmentIndex)
    this.planPageViewModel.activityRemoved(activityId, barSegmentIndex)
  }
}
