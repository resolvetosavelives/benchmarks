import { Controller } from "stimulus"

const SCORES = [0, 1, 2, 3, 4, 5]

/* This controller continuously validates its score/goal pair in the
 * assessment and goal setting page. It checks first that the score and goal
 * are set to allowed values, if each has valid values then it verifies that the
 * score value does not exceeds the goal value.
 *
 * Targets:
 *   scoreTarget -- the score's number input field
 *
 *   goalTarget -- the goal's number input field
 *
 */
export default class extends Controller {
  static targets = ["score", "goal"]

  initialize() {
    this.parentController = this.application.controllers.find(controller => {
      return controller.context.identifier === "score";
    });
    this.parentController.childControllers.push(this)
    this.isFullyValid = true
  }

  connect() {
    $('[data-toggle="tooltip"]').tooltip({
      trigger: "manual",
      container: "#new_goal_form"
    })
  }

  validatePair(event, field) {
    let currentField
    if (field) { // NB: this is used in testing only cuz events are diff there
      currentField = field
    } else {
      currentField = event.currentTarget
    }
    let returnValue = null

    const isValidScore = this.isFieldValid(this.scoreTarget)
    const isValidGoal = this.isFieldValid(this.goalTarget)
    const isValidPair = this.isFieldPairValid(currentField)

    // hide all tooltips if any are invalid cuz state could be anything
    if (!isValidScore || !isValidGoal || !isValidPair) {
      $(this.scoreTarget).tooltip("hide")
      $(this.goalTarget).tooltip("hide")
      this.isFullyValid = false
    }

    if (!isValidScore && !isValidGoal) {
      $(currentField).tooltip("show")
      returnValue = 1
    } else if (!isValidScore) {
      $(this.scoreTarget).tooltip("show")
      returnValue = 2
    } else if (!isValidGoal) {
      $(this.goalTarget).tooltip("show")
      returnValue = 3
    } else if (isValidScore && isValidGoal && !isValidPair) {
      $(currentField).tooltip("show")
      returnValue = 4
    } else { // all valid
      $(this.scoreTarget).tooltip("hide")
      $(this.goalTarget).tooltip("hide")
      this.isFullyValid = true
      returnValue = 5
    }

    this.parentController.setFieldColor(currentField)
    // update the parent form
    this.parentController.updateFormStateFromChildren()

    return returnValue
  }

  isFieldValid(field) {
    field.setCustomValidity("")
    let isValid = null
    if (field.value.length === 0) {
      field.setCustomValidity("invalid")
      field.setAttribute("data-original-title", "The value cannot be empty")
      isValid = false
    } else if (!SCORES.includes(Number(field.value))) {
      field.setCustomValidity("invalid")
      field.setAttribute(
          "data-original-title",
          "The value must be within range"
      )
      isValid = false
    } else {
      isValid = true
    }
    field.parentElement.classList.add("was-validated")
    return isValid
  }

  isFieldPairValid(currentField) {
    if (Number(this.scoreTarget.value) > Number(this.goalTarget.value)) {
      currentField.setCustomValidity("invalid")
      currentField.setAttribute(
          "data-original-title",
          "The goal must be higher than the capacity score"
      )
      return false
    }
    return true
  }

  isValid() {
    return this.isFullyValid
  }

}
