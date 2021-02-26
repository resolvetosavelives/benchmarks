import { Controller } from "stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = [
    "form",
    "planByTechnicalAreasContainerForJee1",
    "planByTechnicalAreasContainerForSpar2018",
    "cardOfTechnicalAreasForJee1",
    "cardOfTechnicalAreasForSpar2018",
    "checkboxForTechnicalArea",
    "submit",
  ]

  connect() {
    this.namedIds = this.data.get("namedIds")
    $(this.countrySelectTarget).chosen({
      no_results_text: "No countries match",
    })
  }

  validateForm(event) {
    if (!this.formTarget.checkValidity()) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.formTarget.classList.add("was-validated")
  }

  selectAssessmentJee1() {
    if (this.hasPlanByTechnicalAreasContainerForSpar2018Target) {
      // when the selected country does not have Spar2018 assessment the element wont be there
      $(this.planByTechnicalAreasContainerForSpar2018Target).hide()
    }
    $(this.planByTechnicalAreasContainerForJee1Target).fadeIn()
  }

  selectAssessmentSpar2018() {
    if (this.hasPlanByTechnicalAreasContainerForJee1Target) {
      // when the selected country does not have JEE1 assessment the element wont be there
      $(this.planByTechnicalAreasContainerForJee1Target).hide()
    }
    $(this.planByTechnicalAreasContainerForSpar2018Target).fadeIn()
  }

  toggleTechnicalAreasForJee1() {
    $(this.cardOfTechnicalAreasForJee1Target).collapse("toggle")
  }

  toggleTechnicalAreasForSpar2018() {
    $(this.cardOfTechnicalAreasForSpar2018Target).collapse("toggle")
  }

  selectAllTechnicalAreasForJee1(event) {
    event.preventDefault()
    event.stopPropagation()
    $(this.cardOfTechnicalAreasForJee1Target)
      .find("input[type=checkbox]")
      .prop("checked", true)
  }

  deselectAllTechnicalAreasForJee1(event) {
    event.preventDefault()
    event.stopPropagation()
    $(this.cardOfTechnicalAreasForJee1Target)
      .find("input[type=checkbox]")
      .prop("checked", false)
  }

  selectAllTechnicalAreasForSpar2018(event) {
    event.preventDefault()
    event.stopPropagation()
    $(this.cardOfTechnicalAreasForSpar2018Target)
      .find("input[type=checkbox]")
      .prop("checked", true)
  }

  deselectAllTechnicalAreasForSpar2018(event) {
    event.preventDefault()
    event.stopPropagation()
    $(this.cardOfTechnicalAreasForSpar2018Target)
      .find("input[type=checkbox]")
      .prop("checked", false)
  }
}
