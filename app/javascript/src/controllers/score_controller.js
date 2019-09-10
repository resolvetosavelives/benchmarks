import { Controller } from "stimulus"
import $ from "jquery"

const SCORES = [0, 1, 2, 3, 4, 5]

/* This controller continuously validates all of the score entries in the
 * assessment and goal setting page. It checks first that the score and goal
 * are set to allowed values, and verifies that the score never exceeds the
 * goal.
 *
 * A goals page can be of arbitrary length and has an arbitrary set of fields
 * involved, so we cannot use the normal Stimulus targets as much as we
 * normally would. Instead, the validation functions search the DOM to find the
 * pair of the element that has just been edited.  Technically, we could
 * perhaps avoid this by keeping a dictionary of the scores and goals as an
 * instance field of this class.
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

  connect() {
    $('[data-toggle="tooltip"]').tooltip({
      trigger: "manual",
      container: "#new_goal_form"
    })
  }

  /* Validate the current field, creating a popup if something is incorrect.
   *
   * For a field to be valid, it must contain one of the allowed values, 0 - 5
   * (integers). Additionally, the score field but not exceed the goal field.
   *
   * This function is able to find the field paired to the one being edited
   * through the naming scheme in which a goal field is named after its
   * corresponding score field, with the term "_goal" appended.
   */
  validate(e) {
    const { currentTarget: field } = e
    const assessmentType = this.formTarget.getAttribute("data-type")
    const isGoal = field.getAttribute("data-goal") === "true"
    field.setCustomValidity("")

    if (field.value.length === 0) {
      field.setCustomValidity("invalid")
      field.setAttribute("data-original-title", "The value cannot be empty")
    } else if (!SCORES.includes(Number(field.value))) {
      field.setCustomValidity("invalid")
      field.setAttribute(
        "data-original-title",
        "The value must be within range"
      )
    } else if (isGoal) {
      const score_field = document.getElementById(field.id.replace("_goal", ""))
      if (Number(score_field.value) > Number(field.value)) {
        field.setCustomValidity("invalid")
        field.setAttribute(
          "data-original-title",
          "The goal must be higher than the capacity score"
        )
      }
    } else {
      const goal_field = document.getElementById(field.id + "_goal")
      if (Number(goal_field.value) < Number(field.value)) {
        field.setCustomValidity("invalid")
        field.setAttribute(
          "data-original-title",
          "The capacity score must be lower than the goal"
        )
      }
    }

    field.parentElement.classList.add("was-validated")

    if (this.formTarget.checkValidity() === false) {
      this.submitButtonTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitButtonTarget.removeAttribute("disabled")
    }

    if (field.checkValidity()) {
      field.classList.remove(
        ...Array.from(field.classList).filter(c => c.match("color-score"))
      )
      field.classList.add(`color-score-${field.value}`)
      $(field).tooltip("hide")
    } else {
      $(field).tooltip("show")
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
