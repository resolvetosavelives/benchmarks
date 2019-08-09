import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["assessmentTypes", "selectedCountry", "selectables"];

  select(e) {
    const countryName = this.selectedCountryTarget.value;
    console.log("Country selected: ", countryName);
  }
}
