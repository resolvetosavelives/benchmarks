import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["selectables", "selectedCountry", "assessmentTypes"]
  openModal(e) {
    $("#joint-country-selection-modal").modal()
  }

  select_country(e) {
    const countryName = this.selectedCountryTarget.value
    const assessmentTypes = this.selectables[countryName]
    this.assessmentTypesTarget.childNodes.forEach(n =>
      this.assessmentTypesTarget.removeChild(n)
    )
    assessmentTypes.forEach(type =>
      this.assessmentTypesTarget.add(new Option(type))
    )
  }

  get selectables() {
    return JSON.parse(this.selectablesTarget.value)
  }
}
