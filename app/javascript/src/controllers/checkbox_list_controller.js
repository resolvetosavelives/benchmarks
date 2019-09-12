import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["listItem"]

  selectAll(e) {
    this.listItemTargets.forEach(target => (target.checked = true))
  }

  deselectAll(e) {
    this.listItemTargets.forEach(target => (target.checked = false))
  }
}
