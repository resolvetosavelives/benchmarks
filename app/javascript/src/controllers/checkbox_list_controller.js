import { Controller } from "stimulus"

const STATE_ALL = "☑️"
const STATE_SOME = "—"
const STATE_NONE = "⏹"

export default class extends Controller {
  static targets = ["listItem"]

  connect() {}

  selectAll(e) {
    this.listItemTargets.forEach(target => (target.checked = true))
  }

  deselectAll(e) {
    this.listItemTargets.forEach(target => (target.checked = false))
  }
}
