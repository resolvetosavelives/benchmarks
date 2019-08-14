import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "assessmentTypes",
    "selectedCountry",
    "selectables",
    "selectedCountryModal"
  ]

  select(e) {
    const countryName = this.selectedCountryTarget.value
    const assessmentTypes = this.selectables[countryName]
    console.log(`select ${countryName} ${assessmentTypes}`)
    this.assessmentTypesTarget.childNodes.forEach(n =>
      this.assessmentTypesTarget.removeChild(n)
    )
    assessmentTypes.forEach(type =>
      this.assessmentTypesTarget.add(new Option(type))
    )

    this.selectedCountryModalTarget.value = countryName

    $("#assessment-selection-modal").modal()
  }

  get selectables() {
    return JSON.parse(this.selectablesTarget.value)
  }
}
