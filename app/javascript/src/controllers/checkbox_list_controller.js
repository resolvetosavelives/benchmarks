import { Controller } from "stimulus"

const STATE_ALL = "☑️"
const STATE_SOME = "—"
const STATE_NONE = "⏹"

export default class extends Controller {
  static targets = ["listItem", "selectAllState"]

  connect() {
    this.updateSelectAllState()
  }

  updateSelectAllState() {
    const selected = this.listItemTargets.filter(target => target.checked)
    if (selected.length === this.listItemTargets.length)
      this.selectAllStateTarget.textContent = STATE_ALL
    else if (selected.length === 0)
      this.selectAllStateTarget.textContent = STATE_NONE
    else this.selectAllStateTarget.textContent = STATE_SOME
  }

  selectListItem(e) {
    this.updateSelectAllState()
  }

  selectAll(e) {
    if (
      this.selectAllStateTarget.textContent === STATE_ALL ||
      this.selectAllStateTarget.textContent === STATE_SOME
    ) {
      this.listItemTargets.forEach(target => (target.checked = false))
    } else if (this.selectAllStateTarget.textContent === STATE_NONE) {
      this.listItemTargets.forEach(target => (target.checked = true))
    }
    this.updateSelectAllState()
  }
}
