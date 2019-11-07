import { Controller } from "stimulus"
import $ from "jquery"

/* This controller continuously validates all of the score entries in the
 * assessment and goal setting page. It checks first that the score and goal
 * are set to allowed values, and verifies that the score never exceeds the
 * goal.
 *
 * We used DOM searches instead of stimulus targets to jump between scores and
 * goals. There's no inherent reason we can't use stimulus targets instead. In
 * the context of a validation event, we care about the event's target (score
 * or goal input) and its corresponding pair input. Since the controller spans
 * the entire form, it was simpler to find the pair directly with
 * currentTarget's id and getElementById than traverse a list of goal or score
 * targets. Another reasonable strategy would be to instantiate one controller
 * per pair, and have scoreTarget and goalTarget, but this would require us to
 * re-do the input fields interaction with the submit button.
 *
 * Targets:
 *   submitButton -- the button to submit the form. This controller will enable
 *   or disable the button based on form validity. The button should be of type
 *   submit, but should also call the `submit` method on this controller. The
 *   stimulus action will occur before the form submit, allowing this
 *   controller to block the form submit if the form is invalid.
 *
 *   form -- the functional area of the form. There is one last validity check
 *   before the form gets submitted.
 *
 */
export default class extends Controller {
  static targets = ["form", "submitButton"]

  initialize() {
    this.childControllers = []
  }

  getToGreen(e) {
    document.querySelectorAll("[data-goal=true]").forEach(field => {
      if (field.value < 4) field.value = 4
      this.setFieldColor(field)
    })
  }

  setFieldColor(field) {
    field.classList.remove(
      ...Array.from(field.classList).filter(c => c.match("color-score"))
    )
    field.classList.add(`color-score-${field.value}`)
  }

  updateFormStateFromChildren() {
    const allAreValid = (this.childControllers.every((childController) => {
      return childController.isValid()
    }))
    if (allAreValid) {
      this.submitButtonTarget.removeAttribute("disabled")
    } else {
      this.submitButtonTarget.setAttribute("disabled", "disabled")
    }
  }

  /* Do a final check on the validity of the form. Prevent the submission
   * process if the form is invalid.
   *
   * The logic here is a little confusing, and it might be easier to call
   * `this.form.submit()` directly.
   */
  submit(e) {
    const { currentTarget: form } = e
    if (form.checkValidity() === false) {
      event.preventDefault()
      event.stopPropagation()
    }
    form.classList.add("was-validated")
  }
}
