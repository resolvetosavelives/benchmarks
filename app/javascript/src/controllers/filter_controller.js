import "bootstrap-multiselect"
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    $(this.selectTarget).multiselect({
      buttonWidth: "100%",
      maxHeight: 200,
      inheritClass: true,
      onChange: filter(this),
      nonSelectedText: this.data.get("placeholder")
    })
  }

  technicalAreaRows(id) {
    return Array.from(
      document.getElementsByClassName(`${this.data.get("class-prefix")}-${id}`)
    )
  }
}

// filter is outside the controller because it appears bootstrap-multiselect
// changes the `this` context of its `onChange` method
const filter = controller => () => {
  const selectedOptions = $(controller.selectTarget).val()

  const allOptions = JSON.parse(
    controller.selectTarget.getAttribute("data-options")
  )

  if (selectedOptions.length) {
    allOptions.forEach(id => {
      if (selectedOptions.includes(id)) {
        controller.technicalAreaRows(id).forEach(r => {
          r.hidden = false
        })
      } else {
        controller.technicalAreaRows(id).forEach(r => {
          r.hidden = true
        })
      }
    })
  } else {
    allOptions.forEach(id => {
      controller.technicalAreaRows(id).forEach(r => {
        r.hidden = false
      })
    })
  }
}
