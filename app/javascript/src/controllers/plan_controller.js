import { Controller } from "stimulus"
import $ from "jquery"
import Chartist from "chartist"
import PlanPageDataModel from "../plan_page_data_model"
import PlanPageViewModel from "../plan_page_view_model"

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
  static targets = ["fieldForActivityIds", "submit", "form", "technicalAreaContainer", "activityCountCircle"]

  initialize() {
    // benchmark controller will append itself to this array
    this.childControllers = []
    this.charts = []
    this.currentChartIndex = 0 // used for tabs and charts arrays
    this.decrementActivityCountCircleUiTimerId = null
    this.planPageDataModel = new PlanPageDataModel(window.STATE_FROM_SERVER)
  }

  connect() {
    this.planPageViewModel = new PlanPageViewModel(this.element)
    this.initDataFromDom()
    this.chartInteractivityEntryPoints = [
      this.initInteractivityForChartByTechnicalArea.bind(this),
      this.initInteractivityForChartByActivityType.bind(this),
    ]
    this.initBarChart()
    this.initActivityCountButton()
    // console.log("plan.connect: this.activityIds.length: ", (this.activityIds || []).length)
    this.initEventListeners()
  }

  initDataFromDom() {
    this.chartSelectors  = JSON.parse(this.data.get("chartSelectors")) // expects an array of strings
    this.chartLabels     = JSON.parse(this.data.get("chartLabels"))    // expects an array of integer arrays
    this.chartDataSeries = JSON.parse(this.data.get("chartSeries"))    // expects an array of integer arrays
    this.chartWidth  = this.data.get("chartWidth")  // expects an integer
    this.chartHeight = this.data.get("chartHeight") // expects an integer
  }

  initEventListeners() {
    // the "shown.bs.tab" event comes of bootstrap nav tabs
    $('a[data-toggle="tab"]').on('shown.bs.tab', (event) => {
      this.handleChartHideShow(event)
    })
    this.element.addEventListener("planActivityAdded", (planActivityAddedEvent) => {
      this.updateFormValidity()
      this.incrementActivityCount(planActivityAddedEvent.detail.barSegmentIndex)
    })
    this.element.addEventListener("planActivityRemoved", (planActivityRemovedEvent) => {
      this.updateFormValidity()
      this.decrementActivityCount(planActivityRemovedEvent.detail.barSegmentIndex)
    })
  }

  updateFormValidity() {
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

  // TODO: no test coverage for this yet because mocking jQuery ($) in the way.
  initActivityCountButton() {
    $(".activity-count-circle").on('click', () => {
      $("#activity-list-by-type-container").hide()
      $(".technical-area-container").show()
    })
  }

  initBarChart() {
    const dataSet = this.chartDataSeries[this.currentChartIndex]
    let data = {
      labels: this.chartLabels[this.currentChartIndex],
      series: [dataSet]
    };
    const heightValue = this.getNextMultipleOfTenForSeries(dataSet)
    let options = {
      high: heightValue,
      low: 0,
      width: this.chartWidth,
      height: this.chartHeight,
      axisY: {
        // show only even-numbered X-axis labels
        labelInterpolationFnc: function (value, index) {
          return value % 10 == 0  ? value: null;
        }
      },
    };
    this.charts[this.currentChartIndex] = new Chartist.Bar(this.chartSelectors[this.currentChartIndex], data, options);
    this.charts[this.currentChartIndex].on('created', () => {
      this.chartInteractivityEntryPoints[this.currentChartIndex]()
    })
  }

  updateChart() {
    this.charts[this.currentChartIndex].update()
  }

  getNextMultipleOfTenForSeries(seriesArray) {
    const maxInt = Math.max(...seriesArray)
    const currentMultipleOfTen = Math.floor(maxInt / 10)
    return (currentMultipleOfTen + 1) * 10
  }

  // e.target: newly activated tab
  // e.relatedTarget: previously active tab
  // TODO: modify this to use PlanPageViewModel events instead?
  handleChartHideShow(event) {
    const {target: selectedTab} = event
    const zeroBasedTabIndex = $(selectedTab).parents("ul").find("a").index(selectedTab)
    this.currentChartIndex = zeroBasedTabIndex
    this.initBarChart()
  }

  // TODO: add test coverage for this now that its unblocked
  initInteractivityForChartByTechnicalArea() {
    // query for bar segments only within the selector of the current chart
    $("line.ct-bar", this.chartSelectors[this.currentChartIndex]).each((segmentIndex, el) => {
      let $elBarSegment = $(el)
      this.initClickHandlerForChartByTechnicalArea($elBarSegment, segmentIndex)
      this.initTooltipForSegmentOfChartByTechnicalArea($elBarSegment, segmentIndex)
    })
  }

  // TODO: add test coverage for this now that its unblocked
  initClickHandlerForChartByTechnicalArea($elBarSegment, index) {
    const chartLabels = this.chartLabels[this.currentChartIndex]
    if (chartLabels[index]) {
      $($elBarSegment).on('click', () => {
        $("#activity-list-by-type-container").hide()
        $('.technical-area-container').hide()
        $('#technical-area-' + chartLabels[index]).show()
      })
    }
  }

  // TODO: add test coverage for this now that its unblocked
  initTooltipForSegmentOfChartByTechnicalArea($elBarSegment, index) {
    const chartLabels = this.chartLabels[this.currentChartIndex]
    let $elTitle = $('#technical-area-' + chartLabels[index])
    let tooltipTitle = $elTitle.attr("title") + ": " + $elBarSegment.attr("ct:value")
    $elBarSegment
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .tooltip({container: ".plan-container"})
        .tooltip()
  }

  initInteractivityForChartByActivityType() {
    // query for bar segments only within the selector of the current chart
    $("line.ct-bar", this.chartSelectors[this.currentChartIndex]).each((segmentIndex, el) => {
      let $elBarSegment = $(el)
      this.initTooltipForSegmentOfChartByActivityType($elBarSegment, segmentIndex)
      this.initClickHandlerForSegmentOfChartByActivityType($elBarSegment, segmentIndex)
    })
  }

  initTooltipForSegmentOfChartByActivityType($elBarSegment, segmentIndex) {
    const chartLabels = this.chartLabels[this.currentChartIndex]
    let tooltipTitle = chartLabels[segmentIndex] + ": " + $elBarSegment.attr("ct:value")
    $elBarSegment
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .tooltip({container: ".plan-container"})
        .tooltip()
  }

  initClickHandlerForSegmentOfChartByActivityType($elBarSegment, segmentIndex) {
      $($elBarSegment).on('click', () => {
        this.filterByActivityType(segmentIndex)
      })
  }

  // generates some HTML and appends it to the DOM and hides the other
  filterByActivityType(segmentIndex) {
    const chartLabels = this.chartLabels[this.currentChartIndex]
    const selectedActivityType = chartLabels[segmentIndex]
    if (selectedActivityType) {
      const $activityTypeHeading = $("<h2>" + selectedActivityType + " actions</h2>")
      // needs to be wrapped in a div.col in order to work with bootstrap grid
      const $activityTypeContainer = $("<div class='col'></div>")
      const $activityRowContent = $('.activity.row.activity-type-' + (segmentIndex  + 1)).clone()
      $activityRowContent.attr("data-activity-bar-segment-index", segmentIndex)
      $activityTypeContainer.append($activityRowContent)
      $('.technical-area-container').hide()
      $("#activity-list-by-type-container")
          .empty()
          .append($activityTypeHeading)
          .append($activityTypeContainer)
          .show()
    }
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

  saveActivityIdsToField() {
    console.log("plan.saveActivityIdsToField: this.getActivityIds().length: ", this.getActivityIds().length)
    this.fieldForActivityIdsTarget.value = JSON.stringify(this.getActivityIds())
  }

  setFormIsValid() {
    this.submitTarget.removeAttribute("disabled")
    this.formTarget.removeAttribute("disabled")
    this.formTarget.classList.add("was-validated")
  }

  setFormIsInvalid() {
    this.submitTarget.setAttribute("disabled", "disabled")
    this.formTarget.setAttribute("disabled", "disabled")
    this.formTarget.classList.add("was-validated")
  }

  incrementActivityCount(barSegmentIndex) {
    this.incrementActivityCountCircleUI()
    this.incrementChartSegmentCountData(barSegmentIndex)
    this.updateChart()
  }

  decrementActivityCount(data) {
    this.decrementActivityCountCircleUI()
    this.decrementChartSegmentCountData(data)
    this.updateChart()
  }

  incrementActivityCountCircleUI() {
    console.log("GVT: incrementActivityCountCircleUI..")
    if (this.hasActivityCountCircleTarget) {
      this.activityCountCircleTarget.textContent = this.currentActivityCount()
    }
  }

  // NB: this one is a little tricky because when an indicator is deleted all of the activities it contains
  // are deleted in which causes to rapid invocations of this function and hence many/rapid DOM updates which
  // causes some of those updates to be skipped/lost/discard in the flurry of activity.
  // to solve this we have a kind of "debounce" implementation to delay a DOM update until 10ms has passed.
  decrementActivityCountCircleUI() {
    if (this.hasActivityCountCircleTarget) {
      // the first time this is run the decrementActivityCountCircleUiTimerId will be null.
      // subsequent invocations will have the decrementActivityCountCircleUiTimerId set to a value
      // when there is a previous invocation but its setTimeout function has not yet triggered, which
      // is when we want to clear it to avoid overly-rapid DOM updates.
      if (this.decrementActivityCountCircleUiTimerId) {
        clearTimeout(this.decrementActivityCountCircleUiTimerId)
      }
      this.decrementActivityCountCircleUiTimerId = setTimeout(() => {
        this.activityCountCircleTarget.textContent = this.currentActivityCount()
      }, 10) // 10ms should be enough
    }
  }

  incrementChartSegmentCountData(barSegmentIndex) {
    this.chartDataSeries[this.currentChartIndex][barSegmentIndex]++
  }

  decrementChartSegmentCountData(barSegmentIndex) {
    this.chartDataSeries[this.currentChartIndex][barSegmentIndex]--
  }

  getActivityIds() {
    return this.planPageDataModel.activityIds
  }

  currentActivityCount() {
    return this.planPageDataModel.currentActivityCount()
  }
}
