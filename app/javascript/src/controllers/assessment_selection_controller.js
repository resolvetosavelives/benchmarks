import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "assessmentTypes",
    "getStartedButton",
    "selectedCountry",
    "selectables",
    "selectedCountryName",
    "selectedCountryModal",
    "submitForm"
  ]

  connect() {
    this.selectedCountryTarget.value = Object.keys(this.selectables)[0]
    this.selectCountry()
  }

  openModal(e) {
    $("#assessment-selection-modal").modal()
  }

  openModalValidated(e) {
    if (this.isCountryValid()) this.openModal(e)
  }

  isCountryValid() {
    return this.selectedCountryTarget.value !== "-- Select One --"
  }

  isAssessmentTypeValid() {
    return (
      this.assessmentTypesTarget.selectedOptions[0].value !== "-- Select One --"
    )
  }

  validateAndEnableGetStarted(e) {
    this.getStartedButtonTarget.disabled = !this.isCountryValid()
  }

  validateAndEnableNext(e) {
    this.submitFormTarget.disabled = !(
      this.isCountryValid() && this.isAssessmentTypeValid()
    )
  }

  selectCountry(e) {
    const countryName = this.selectedCountryTarget.value
    const assessmentTypes = [
      { type: "-- Select One --", text: "-- Select One --" }
    ].concat(this.selectables[countryName])
    while (this.assessmentTypesTarget.firstChild)
      this.assessmentTypesTarget.removeChild(
        this.assessmentTypesTarget.firstChild
      )
    assessmentTypes.forEach(type =>
      this.assessmentTypesTarget.add(new Option(type.text, type.type))
    )

    if (this.hasSelectedCountryNameTarget)
      this.selectedCountryNameTarget.textContent = countryName

    if (this.hasSelectedCountryModalTarget)
      this.selectedCountryModalTarget.value = countryName
  }

  selectCountryAndOpen(e) {
    this.selectCountry(e)
    this.openModal()
  }

  get selectables() {
    return JSON.parse(this.selectablesTarget.value)
  }
}
