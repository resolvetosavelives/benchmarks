import { Controller } from "stimulus"

const SCORES = [0, 1, 2, 3, 4, 5]

export default class extends Controller {
  static targets = ["form", "submitButton"]

  validate(e) {
    const { currentTarget: field } = e
    const assessmentType = this.formTarget.getAttribute("data-type")
    const isGoal = field.getAttribute("data-goal") === "true"
    field.setCustomValidity("")

    if (field.value.length === 0) {
      field.setCustomValidity("invalid")
    } else if (!SCORES.includes(Number(field.value))) {
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

    if (field.checkValidity()) {
      field.classList.remove(
        ...Array.from(field.classList).filter(c => c.match("color-score"))
      )
      field.classList.add(`color-score-${field.value}`)
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
