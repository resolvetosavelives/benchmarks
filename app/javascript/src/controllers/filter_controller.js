import "bootstrap-multiselect"
import { Controller } from "stimulus"

/* This controller handles filtering the draft plan. It is fairly general and
 * is used to filter the technical areas in the goals page and the activity
 * types in the draft plan page.
 *
 * Parameters:
 *   placeholder -- a placeholder option in the dropdown.
 *
 *   class-prefix -- this designates a prefix for class names that are used to
 *   tag elements that this controller may hide or delete. Setting this value
 *   to "type-code" will make the controller process every element that has the
 *   class "type-code-<some text>" in it. For instance,
 *   type-code-monitoring-and-evaluation, type-code-training, and so forth.
 *
 * Targets:
 *   select -- this is the selection dropdown, and is how the user selects
 *   which types should be visible.
 *
 * The visible filtering process is done through normal DOM manipulations.
 * Every element that has a class with the prefix "type-code-" will be subject
 * to being hidden or made visible depending on which type codes have been
 * enabled.
 */
export default class extends Controller {
  static targets = ["select"]

  connect() {
    if (
      $(this.selectTarget)
        .siblings()
        .find(".multiselect").length === 0
    ) {
      $(this.selectTarget).multiselect({
        buttonWidth: "100%",
        maxHeight: 200,
        inheritClass: true,
        onChange: filter(this),
        nonSelectedText: this.data.get("placeholder")
      })
    }
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
