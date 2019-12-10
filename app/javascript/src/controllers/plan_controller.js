import { Controller } from "stimulus"
import $ from "jquery"
import Chartist from "chartist"

// TODO: test coverage for recent changes

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
  static targets = ["fieldForActivityIds", "submit", "form"]

  initialize() {
    // benchmark controller will append itself to this array
    this.childControllers = []
  }

  connect() {
    this.initBarChart()
    this.initActivityCountButton()
    console.log("plan.connect: getActivityIds().length: ", this.getActivityIds().length)
    if (document.referrer.match("goals")) {
      $("#draft-plan-review-modal").modal("show")
    }
  }

  getActivityIds() {
    return JSON.parse(this.data.get("activityIds"))
  }

  setActivityIds(activityIds) {
    this.data.set("activityIds", JSON.stringify(activityIds))
    let anyActivities = false
    this.childControllers.forEach((controller) => {
      if (controller.hasActivities()) {
        anyActivities = true
      }
    })
    if (anyActivities === true) {
      this.setFormIsValid()
    } else {
      this.setFormIsInvalid()
    }
  }

  addActivityId(activityId) {
    const allPlanActivityIds = this.getActivityIds()
    const indexOfActivityId = allPlanActivityIds.indexOf(activityId)
    if (indexOfActivityId === -1) {
      allPlanActivityIds.push(activityId)
      this.setActivityIds(allPlanActivityIds)
    }
  }

  removeActivityId(activityId) {
    const allPlanActivityIds = this.getActivityIds()
    const indexOfActivityId = allPlanActivityIds.indexOf(activityId)
    if (indexOfActivityId >= 0) {
      allPlanActivityIds.splice(indexOfActivityId, 1)
      this.setActivityIds(allPlanActivityIds)
    }
  }

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  initActivityCountButton() {
    $(".activity-count-circle").click(() => {
      $(".technical-area-container").show()
    })
  }

  initBarChart() {
    let chartSelector = this.data.get("chartSelector")
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
    this.chart = new Chartist.Bar(chartSelector, data, options);
    this.chart.on('created', () => {
      this.initBarChartInteractivity()
    })
  }

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  initBarChartInteractivity() {
    $("line.ct-bar").each((index, el) => {
      let $elBarSegment = $(el)
      this.initClickHandlerForTAChart($elBarSegment, index)
      this.initTooltipForTAChartSegment($elBarSegment, index)
    })
  }

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  initClickHandlerForTAChart($elBarSegment, index) {
    if (this.chartLabels[index]) {
      $($elBarSegment).on('click', () => {
        $('.technical-area-container').hide()
        $('#technical-area-' + this.chartLabels[index]).show()
      })
    }
  }

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  initTooltipForTAChartSegment($elBarSegment, index) {
    let $elTitle = $('#technical-area-' + this.chartLabels[index])
    let tooltipTitle = $elTitle.attr("title") + ": " + $elBarSegment.attr("ct:value")
    $elBarSegment
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .tooltip({container: ".plan-container"})
        .tooltip()
  }

  /* Check the validity of the plan name, disabling the submit button if the
   * name is invalid. */
  validateName() {
    if (this.formTarget.checkValidity() === false) {
      this.setFormIsInvalid()
    } else {
      this.setFormIsValid()
    }
  }

  submit() {
    let allBenchmarkActivityIds = this.data.get("activityIds")
    console.log("plan.submit: allBenchmarkActivityIds.length: ", JSON.parse(allBenchmarkActivityIds).length)
    this.fieldForActivityIdsTarget.value = allBenchmarkActivityIds
    this.formTarget.submit()
  }

  setFormIsValid() {
    this.submitTarget.removeAttribute("disabled")
    this.formTarget.classList.add("was-validated")
  }

  setFormIsInvalid() {
    this.submitTarget.setAttribute("disabled", "disabled")
    this.formTarget.classList.add("was-validated")
  }
}
