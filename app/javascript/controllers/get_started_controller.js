import { Controller } from "stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = [
    "technicalAreaCard",
    "checkboxForTechnicalArea",
    "countrySelect",
    "form",
    "planByTechnicalAreasContainer",
    "submit",
  ]

  static values = { namedIds: Array }

  connect() {
    this.$ = $

    if (this.hasCountrySelectTarget) {
      $(this.countrySelectTarget).chosen({
        no_results_text: "No countries match",
      })
    }
  }

  validateForm(event) {
    if (!this.formTarget.checkValidity()) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.formTarget.classList.add("was-validated")
  }

  selectAssessment(e) {
    $(this.planByTechnicalAreasContainerTargets)
      .hide()
      .filter('[data-assessment-named-id="' + e.target.value + '"]')
      .show()
  }

  toggleTechnicalAreas(e) {
    $(this.technicalAreaCardTargets)
      .filter(
        '[data-assessment-named-id="' +
          e.target.dataset.assessmentNamedId +
          '"]'
      )
      .collapse("toggle")
  }

  selectAllTechnicalAreas(e) {
    e.preventDefault()
    e.stopPropagation()

    $(this.technicalAreaCardTargets)
      .filter(
        '[data-assessment-named-id="' +
          e.target.dataset.assessmentNamedId +
          '"]'
      )
      .find("input[type=checkbox]")
      .prop("checked", true)
  }

  deselectAllTechnicalAreas(e) {
    e.preventDefault()
    e.stopPropagation()

    $(this.technicalAreaCardTargets)
      .filter(
        '[data-assessment-named-id="' +
          e.target.dataset.assessmentNamedId +
          '"]'
      )
      .find("input[type=checkbox]")
      .prop("checked", false)
  }
}
