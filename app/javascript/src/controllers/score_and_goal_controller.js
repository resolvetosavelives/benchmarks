import { Controller } from "stimulus"
import $ from "jquery"

const SCORES = [0, 1, 2, 3, 4, 5]

// TODO: update this comment
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
    window.app = this.application
  }

  validatePair(e) {
    const {currentTarget: currentField} = e

    const isValidScore = this.isFieldValid(this.scoreTarget)
    const isValidGoal = this.isFieldValid(this.goalTarget)
    const isValidPair = this.isFieldPairValid(currentField)
    console.log("GVT: isValidScore, isValidGoal, isValidPair", isValidScore, isValidGoal, isValidPair)


    // hide all tooltips if any are invalid cuz state could be anything
    if (!isValidScore || !isValidGoal || !isValidPair) {
      $(this.scoreTarget).tooltip("hide")
      $(this.goalTarget).tooltip("hide")
      this.isFullyValid = false
    }

    if (!isValidScore && !isValidGoal) {
      console.log("GVT: WHICH: !isValidScore && !isValidGoal")
      $(currentField).tooltip("show")
    } else if (!isValidScore) {
      console.log("GVT: WHICH: invalid score, show tooltip", currentField, this.scoreTarget)
      $(this.scoreTarget).tooltip("show")
    } else if (!isValidGoal) {
      console.log("GVT: WHICH: invalid goal, show tooltip", currentField, this.goalTarget)
      $(this.goalTarget).tooltip("show")
    } else if (isValidScore && isValidGoal && !isValidPair) {
      console.log("GVT: WHICH: isValidScore && isValidGoal && !isValidPair")
      $(currentField).tooltip("show")
    } else { // all valid
      console.log("GVT: WHICH: ELSE should not hit")
      $(this.scoreTarget).tooltip("hide")
      $(this.goalTarget).tooltip("hide")
      this.isFullyValid = true
    }

    this.parentController.setFieldColor(currentField)
    // update the parent form
    this.parentController.updateFormStateFromChildren()
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
