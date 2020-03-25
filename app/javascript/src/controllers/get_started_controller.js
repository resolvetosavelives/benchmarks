import { Controller } from "stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = [
    "form",
    "countrySelect",
    "planByTechnicalAreasContainerForJee1",
    "planByTechnicalAreasContainerForSpar2018",
    "cardOfTechnicalAreasForJee1",
    "cardOfTechnicalAreasForSpar2018",
    "checkboxForTechnicalArea",
    "submit",
  ]

  connect() {
    this.redirectKey = this.data.get("redirectKey")
    this.namedIds = this.data.get("namedIds")
    $(this.countrySelectTarget).chosen({
      no_results_text: "No countries match",
    })
    $(this.countrySelectTarget).on(
      "change",
      this.presubmitFormToLoadOtherFields.bind(this)
    )
    $(this.element).on(
      "ajax:success",
      this.updateFormControlsFromServerResponse.bind(this)
    )
    $(this.element).on("ajax:error", this.handleAjaxError.bind(this))
    const selectedCountryCode = this.countrySelectTarget.value
    // the purpose of this conditional and the variable submittedGetStartedAtLeastOnce is
    // to handle when we end up on this page via Back Button usage, because in this
    // case the select menu will have a value but no events have fired. So here we
    // trigger an event in order to populate form options for the pre-selected value.
    if (selectedCountryCode && !window.submittedGetStartedAtLeastOnce) {
      $(this.countrySelectTarget).trigger("change")
    }
  }

  presubmitFormToLoadOtherFields() {
    // the following reset/set flow is done to fix
    // the bug reported here: https://www.pivotaltracker.com/story/show/171721472
    const countryValue = this.countrySelectTarget.value
    this.formTarget.reset()
    this.countrySelectTarget.value = countryValue

    window.submittedGetStartedAtLeastOnce = true
    $(this.formTarget).submit()
  }

  // the API arguments here come from jQuery Ajax
  updateFormControlsFromServerResponse(jqEvent, responseData) {
    // match at the beginning only because its elsewhere in the response
    const regex = new RegExp("^" + this.redirectKey)
    const isRedirect = regex.test(responseData)
    // when the form is filled completely the server responds with a redirect
    // the handling here is to workaround XHR being unable to detect a redirect.
    if (isRedirect) {
      const url = responseData.split(this.redirectKey)[1]
      window.location.href = url
    } else {
      // this is when the form is not yet filled and responses fill form options.
      // responseData is expected to be an HTML fragment of the template without a layout
      $(this.element).replaceWith(responseData)
    }
  }

  handleAjaxError(jqEvent, xhr, status, errMsg) {
    console.log(
      "An error occurred while submitting the form via Ajax: ",
      errMsg
    )
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
