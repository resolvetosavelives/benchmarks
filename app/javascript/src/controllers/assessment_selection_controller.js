import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "assessmentTypes",
    "selectedCountry",
    "selectables",
    "selectedCountryName",
    "selectedCountryModal"
  ]

  connect() {
    this.selectedCountryTarget.value = Object.keys(this.selectables)[0]
    this.selectCountry()
  }

  openModal(e) {
    $("#assessment-selection-modal").modal()
  }

  selectCountry(e) {
    const countryName = this.selectedCountryTarget.value
    const assessmentTypes = this.selectables[countryName]
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
