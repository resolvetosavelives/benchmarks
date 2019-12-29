import { Controller } from "stimulus"

export default class extends Controller {

  initialize() {
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "benchmark";
    });
    this.parentController.childControllers.push(this)
  }

  connect() {
    this.technicalAreaId = Number(this.data.get("technicalAreaId"))
    this.indicatorId = Number(this.data.get("indicatorId"))
    this.id = Number(this.data.get("id"))
    this.barSegmentIndex = Number(this.data.get("barSegmentIndex"))
  }

  deleteSelf(e) {
    const { currentTarget } = e
    this.removeActivityId(this.id, {barSegmentIndex: this.barSegmentIndex})
    currentTarget.closest(".row").classList.add("d-none")
  }

  removeActivityId(activityId, data) {
    this.parentController.removeActivityId(activityId, data)
  }
}
