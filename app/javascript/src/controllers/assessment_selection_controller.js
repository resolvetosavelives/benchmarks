import { Controller } from "stimulus"
/* This controller handles all of the modal dialogue boxes involved with
 * assessment selection. The functions here support two different workflows
 * (and an envolving understanding of Stimulus).
 *
 * This is actually a multi-step modal with varying steps, more wizard-like
 * than a modal. Current state must be stored in the Next button so that it can
 * be submitted to this controller when the button is pressed. The button also
 * dictates which state the modal is going into.
 *
 * In that light, known states are null, "assessment-selection-modal" and
 * "from-capacities".
 *
 *   null -- no modal is currently open
 *
 *   assessment-selection-modal -- the assessment selection modal is open. This
 *   could be either the version that already knows the country and shows only
 *   the list of possible assessments (_assessment_selection_modal.html.erb),
 *   or the version that shows both the country list and the assessment list
 *   (_joint_assessment_selection_modal.html.erb).
 *
 *   from-capacities -- the modal for selecting the capacities for an
 *   assessment is open (_capacity_selection_modal.html.erb).
 *
 *   If the current state is `assessment-selection-modal` and the
 *   `assessmentTypeSelect` value is `from-capacities`, the transition to the
 *   capacities dialogue will be honored. `assessmentTypeSelect` is anything
 *   else, it will be assumed to be an actual assessment type, and the entire
 *   form will be submitted, instead.
 *
 * The "next" button in a dialog needs to provide both the current state
 * (`data-current` and the next state `data-next`).
 *
 * Targets that provide data to the page:
 *   getStartedButton -- the green "Get Started" button that appears on the
 *   landing page. The controller toggles the button's enabled/disabled status.
 *
 *   countryNameLabel -- this also carries the country name, solely for
 *   populating the country name in the dialogue copy.
 *
 *   submitForm -- this is the button that either submits the form or
 *   transitions to the next step of the dialog. The controller toggles the
 *   button's enabled/disabled status.
 *
 *   countryName -- this carries the country name for populating into hidden
 *   fields.
 *
 * Targets that provide page data to the controller:
 *
 *   selectables -- contains a JSON-encoded dictionary of all of the countries
 *   and their associated assessments. The server populates this in the page
 *   when it renders the page.
 *
 *   form -- the entire form itself. This must contain all of the fields to be
 *   submitted, including hidden fields. The form generally does not get
 *   submitted from the web page any more, but instead from the next function
 *   of this controller.
 *
 * Targets that can do both:
 *   countrySelect -- the country selection dropdown. The controller can use
 *   this to change the currently selected country (but does not do so at this
 *   time), and to read the currently selected country. This helps the
 *   controller determine whether the form is valid, and what assessment types
 *   need to be populated.
 *
 *   assessmentTypeSelect -- this is the assessment types dropdown, and this
 *   controller clears and repopulates it whenever the country selection
 *   changes. The controller also reads it when determining whether the entire
 *   form is valid.
 */
export default class extends Controller {
  static targets = [
    "form",
    "countrySelect",
    "assessmentTypeSelect",
    "getStartedButton",
    "countryName",
    "countryNameLabel",
    "selectables",
    "submitForm"
  ]

  connect() {
    this.selectCountry()
  }

  /* Move to the next step of the state machine.
   *
   * Currently the pages tell the controller what the current state is and what
   * the next state is. But, the controller makes some decisions based on other
   * inputs and may deviate. It would probably be clearer to move all of the
   * state transition logic into this function and the current state tracking
   * into this controller.
   */
  next(e) {
    const currentModal = e.currentTarget.getAttribute("data-current")
    const nextModal = e.currentTarget.getAttribute("data-next")

    if (currentModal === null) {
      $(`#${nextModal}`).modal("show")
    } else if (currentModal === "assessment-selection-modal") {
      $(`#${currentModal}`).modal("hide")

      if (this.assessmentTypeSelectTarget.value === "from-capacities") {
        $(`#${nextModal}`).modal("show")
      } else {
        this.formTarget.submit()
      }
    }
  }

  /* Verify that the current country selection is valid. All selections are
   * valid except for the placeholder. */
  isCountryValid() {
    return this.countrySelectTarget.value !== "-- Select One --"
  }

  /* Verify that the assessment type is valid. Since the assessment type gets
   * auto-populated, the only possible invalid selection is the placeholder. */
  isAssessmentTypeValid() {
    return (
      this.assessmentTypeSelectTarget.selectedOptions[0].value !==
      "-- Select One --"
    )
  }

  /* Enable the Get Started button (getStartedButton target) if the currently
   * selected country is valid. This should only be attached to a pulldown menu
   * on a page that has the getStartedButton target specified. */
  validateAndEnableGetStarted(e) {
    this.getStartedButtonTarget.disabled = !this.isCountryValid()
  }

  /* Enable the "Next" button if both the country and the assessment type are
   * valid. The Next button typically is a form submission, which should not be
   * allowed if the currently selected options are invalid. */
  validateAndEnableNext(e) {
    this.submitFormTarget.disabled = !(
      this.isCountryValid() && this.isAssessmentTypeValid()
    )
  }

  /* Populate the assessment selection pulldown whenever a country gets
   * selected. */
  selectCountry(e) {
    const countryName = this.countrySelectTarget.value
    const assessmentTypes = [
      { type: "-- Select One --", text: "-- Select One --" }
    ]
      .concat(this.selectables[countryName])
      .concat([{ type: "from-capacities", text: "Plan by Capacity Areas" }])
    while (this.assessmentTypeSelectTarget.firstChild)
      this.assessmentTypeSelectTarget.removeChild(
        this.assessmentTypeSelectTarget.firstChild
      )
    assessmentTypes.forEach(type =>
      this.assessmentTypeSelectTarget.add(new Option(type.text, type.type))
    )

    if (this.hasCountryNameLabelTarget)
      this.countryNameLabelTarget.textContent = countryName
    if (this.hasCountryNameTarget)
      this.countryNameTargets.forEach(target => (target.value = countryName))
  }

  /* Special stimulus syntax. This retrieves the selectables target from the
   * page and processes it into an instance field in this Javascript
   * controller.
   */
  get selectables() {
    return JSON.parse(this.selectablesTarget.value)
  }
}
