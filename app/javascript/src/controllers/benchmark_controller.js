import { Controller } from "stimulus"

/* Controller that handles deleting an entire benchmark. This covers only the workflow of pressing and then confirming the delete button on a benchmark given how much data can be deleted at once.
 *
 * Targets:
 *   self -- ???
 *
 *   confirm -- this target is for the initially visible delete button. When
 *   clicked, this button will be hidden and the "Really Delete" button will be
 *   displayed.
 *
 *   delete -- this target for for the "Really Delete" button on the form. If
 *   it is clicked, the delete action will be called.
 *
 * Note: confirm/delete is a little confusing. Consider reversing the names of
 * the two. The idea I am thinking of would be that you click on the delete
 * button, and then click on the delete confirmation button.
 */
export default class extends Controller {
  static targets = ["self", "confirm", "delete"]

  connect() {
    this.deleteTarget.hidden = true
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

  /* Carry out the delete process. */
  delete(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    const activityMap = JSON.parse(this.activityMapTarget.value)
    delete activityMap[benchmarkId]
    this.activityMapTarget.value = JSON.stringify(activityMap)
    this.selfTarget.hidden = true
    const siblings = $(this.selfTarget).siblings(".benchmark-container:visible")
    if (siblings.length === 0) {
      this.selfTarget.parentElement.hidden = true
    }
  }

  get activityMapTarget() {
    return document.querySelector("#plan_activity_map")
  }
}
