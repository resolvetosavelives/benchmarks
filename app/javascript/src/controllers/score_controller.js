import { Controller } from "stimulus"

const SPAR_SCORES = [0, 20, 40, 60, 80, 100]
const JEE_SCORES = [0, 1, 2, 3, 4, 5]

export default class extends Controller {
  static targets = ["form", "submitButton"]

  validate(e) {
    const { currentTarget: field } = e
    const assessmentType = this.formTarget.getAttribute("data-type")
    const scores = assessmentType.match(/spar/) ? SPAR_SCORES : JEE_SCORES
    const isGoal = field.getAttribute("data-goal") === "true"
    field.setCustomValidity("")

    if (field.value.length === 0) {
      field.setCustomValidity("invalid")
    } else if (!scores.includes(Number(field.value))) {
      field.setCustomValidity("invalid")
    }

    if (isGoal) {
      const score_field = document.getElementById(field.id.replace("_goal", ""))
      if (Number(score_field.value) > Number(field.value)) {
        field.setCustomValidity("invalid")
      }
    } else {
      const goal_field = document.getElementById(field.id + "_goal")
      if (Number(goal_field.value) < Number(field.value)) {
        field.setCustomValidity("invalid")
      }
    }

    field.parentElement.classList.add("was-validated")

    if (this.formTarget.checkValidity() === false) {
      this.submitButtonTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitButtonTarget.removeAttribute("disabled")
    }
  }

  submit(e) {
    const { currentTarget: form } = e
    if (form.checkValidity() === false) {
      event.preventDefault()
      event.stopPropagation()
    }
    form.classList.add("was-validated")
  }
}
