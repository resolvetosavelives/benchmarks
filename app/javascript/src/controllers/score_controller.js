import { Controller } from "stimulus"

/* This controller checks its child controllers to determine its form validity
 * and enables or disables its submit button accordingly.
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
