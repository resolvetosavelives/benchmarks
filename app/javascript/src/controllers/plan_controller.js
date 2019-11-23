import { Controller } from "stimulus"
import Chartist from "chartist"
import $ from "jquery"

import renderActivity from "../renderActivity"

/* This controller handles almost all of the in-browser capabilities of the
 * draft plan form. Users can delete activities, add freeform activities, and
 * add known activities because of this controller. All changes are stored in
 * the browser window and will not be saved until the form is submitted.
 *
 * This controller hooks some elements based on data attributes instead of
 * based on targets because of the somewhat sophisticated way it has to deal
 * with the multiple sections in a draft plan. As best as possible, that
 * information is documented with the relevant methods.
 *
 * Note that the controller does not handle deleting entire benchmarks from the
 * draft plan. See benchmark_controller.js
 *
 * Targets:
 *   activityMap -- this field contains all of the activities in the plan,
 *   classified by benchmark ID. The server will populate this field when
 *   rendering the page, and this controller will modify the field as the user
 *   edits the draft plan. Note that the benchmark_controller will also edit
 *   the field.
 *
 *   newActivity -- this is a single target that represents all of the fields
 *   that the user can use to add activities to the plan. Each field must be
 *   tagged with "data-benchmark-id" so this controller knows which benchmark
 *   to add the activity to.
 *
 *   submit -- the submit button for the form. This controller only needs to be
 *   able to toggle the enabled/disabled status of the button. To work with
 *   this controller, the submit button on click should call the `submit`
 *   function on this controller instead of directly submitting the form. We
 *   provide this target and the corresponding `submit` method because the
 *   draft plan layout actually requires that some parts of the "form" live
 *   outside of the form tag.
 *
 *   form -- the functional area of the form. Some parts of the interactive
 *   part of the form lie outside of this element, but all of the data lies
 *   within this element.
 *
 */
export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit", "form"]

  connect() {
    this.initBarChart()
    if (document.referrer.match("goals")) {
      $("#draft-plan-review-modal").modal("show")
    }
  }

  /* Delete an activity from the plan. */
  deleteActivity(e) {
    const { currentTarget } = e
    const activityToDelete = currentTarget.getAttribute("data-activity")
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")

    const newActivityList = this.activityMap[benchmarkId].filter(
      a => a.text !== activityToDelete
    )
    this.activityMapTarget.value = JSON.stringify({
      ...this.activityMap,
      [benchmarkId]: newActivityList
    })
    currentTarget.closest(".row").classList.add("d-none")
    $(this.newActivity(benchmarkId)).autocomplete({
      source: this.autocompletions(benchmarkId)
    })
    this.validateActivityMap()
  }

  /* Add a new activity to a benchmark. The add activity form should have a
   * "data-benchmark-id" tag on it to specify which benchmark to add the
   * activity to, and must call this function to actually add the text in the
   * field. */
  addNewActivity(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    if (e.keyCode === 13 && currentTarget.value.length) {
      this.activityMapTarget.value = JSON.stringify({
        ...this.activityMap,
        [benchmarkId]: [
          ...(this.activityMap[benchmarkId] || []),
          { text: currentTarget.value }
        ]
      })
      renderActivity(benchmarkId, currentTarget.value)
      $(currentTarget).autocomplete({
        source: this.autocompletions(benchmarkId)
      })
      e.target.value = ""
      e.preventDefault()
      this.validateActivityMap()

      const noActivitiesNudge = currentTarget
        .closest(".benchmark-container")
        .querySelector(".no-activities")
      if (noActivitiesNudge) {
        noActivitiesNudge.hidden = true
      }
    }
  }

  /* Get a list of all of the possible activities for a benchmark. */
  autocompletions(benchmarkId) {
    return this.allActivities(benchmarkId).filter(
      a => this.currentActivities(benchmarkId).includes(a) === false
    )
  }

  /* Get the text of all of the current activities for a benchmark in the
   * activity map. */
  currentActivities(benchmarkId) {
    return this.activityMap[benchmarkId]
      ? this.activityMap[benchmarkId].map(a => a.text)
      : []
  }

  /* This provides the list of all possible activities in for a benchmark.
   *
   * The "New Activity" field for each benchmark must have a `data-activites`
   * attribute that that the server must populate with all of the possible
   * activities for this benchmark.
   */
  allActivities(benchmarkId) {
    return JSON.parse(
      this.newActivity(benchmarkId).getAttribute("data-activities")
    )
  }

  /* Retrieve a new activity field for the specified benchmark ID. */
  newActivity(benchmarkId) {
    return this.newActivityTargets.find(
      t => t.getAttribute("data-benchmark-id") === benchmarkId
    )
  }

  /* Check the validity of the plan name, disabling the submit button if the
   * name is invalid. */
  validateName() {
    if (this.formTarget.checkValidity() === false) {
      this.submitTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitTarget.removeAttribute("disabled")
    }
    this.formTarget.classList.add("was-validated")
  }

  /* Check that the draft plan has at least one element in it, and disable the
   * submit button if it does not. */
  validateActivityMap() {
    if (
      Object.keys(this.activityMap).every(
        key => this.activityMap[key].length === 0
      )
    ) {
      this.submitTarget.setAttribute("disabled", "disabled")
    } else {
      this.submitTarget.removeAttribute("disabled")
    }
  }

  /* Submit the form.
   *
   * We cannot use a normal submit button because the submit button lives
   * outside of the form on the page. We had to do this for formatting
   * purposes.
   */
  submit() {
    this.formTarget.submit()
  }

  /* This causes stimulus to convert the activityMapTarget into a instance
   * field.
   */
  get activityMap() {
    return JSON.parse(this.activityMapTarget.value)
  }

  initBarChart() {
    this.chartLabels = JSON.parse(this.data.get("chartLabels"))
    let data = {
      labels: this.chartLabels,
      series: [
        JSON.parse(this.data.get("chartSeries"))
      ]
    };
    let options = {
      high: 40,
      low: 0,
      width: this.data.get("chartWidth"),
      height: this.data.get("chartHeight"),
      axisY: {
        // show only even-numbered X-axis labels
        labelInterpolationFnc: function (value, index) {
          return index % 2 === 0 ? value : null;
        }
      },
    };
    this.chart = new Chartist.Bar(this.data.get("chartSelector"), data, options);
    this.chart.on('created', this.setBarChartEventListeners.bind(this))
  }

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  setBarChartEventListeners() {
    $("line.ct-bar").each((i, el) => {
      let $el = $(el)
      if (this.chartLabels[i]) {
        $($el).on('click', () => {
          $('.capacity-container').hide()
          $('#capacity-' + this.chartLabels[i]).show()
        })
      }
    })
  }
}
