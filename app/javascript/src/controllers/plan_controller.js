import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["activity"]
  deleteActivity(e) {
    console.log("Deleting item", event.target.getAttribute("data-activity"))
  }
}
