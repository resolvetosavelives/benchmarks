import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["select"]

  do(e) {
    const { selectedOptions } = e.currentTarget

    const allOptions = JSON.parse(
      this.selectTarget.getAttribute("data-options")
    )

    const optionsToFilter = Array.from(selectedOptions).map(o => o.value)
    allOptions.forEach(id => {
      if (optionsToFilter.includes(id)) {
        this.technicalAreaRows(id).forEach(e => {
          e.hidden = true
        })
      } else {
        this.technicalAreaRows(id).forEach(e => {
          e.hidden = false
        })
      }
    })
  }

  technicalAreaRows(id) {
    return Array.from(document.getElementsByClassName(`technical_area_${id}`))
  }
}
