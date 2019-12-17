import { Controller } from "stimulus"

export default class extends Controller {

  initialize() {
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "benchmark";
    });
    this.parentController.childControllers.push(this)
  }

  deleteSelf(e) {
    const { currentTarget } = e
    const planActivityIdToRemove = Number(currentTarget.getAttribute("data-benchmark-activity-id"))
    console.log("GVT: planActivityIdToRemove: ", planActivityIdToRemove)
    this.removeActivityId(planActivityIdToRemove)
    currentTarget.closest(".row").classList.add("d-none")
  }

  removeActivityId(activityId) {
    this.parentController.removeActivityId(activityId)
  }
}
