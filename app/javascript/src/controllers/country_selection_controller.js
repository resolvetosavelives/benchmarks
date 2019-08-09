import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["assessmentTypes", "selectedCountry", "selectables"];

  select(e) {
    const countryName = this.selectedCountryTarget.value;
    const assessmentTypes = this.selectables[countryName]
    while (this.assessmentTypesTarget.firstChild) {
      this.assessmentTypesTarget.removeChild(this.assessmentTypesTarget.firstChild)
    }
    assessmentTypes.forEach(type => this.assessmentTypesTarget.add(new Option(type)))
  }

  get selectables() {
    return JSON.parse(this.selectablesTarget.value)
  }
}
