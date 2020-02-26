import { Controller } from "stimulus"
import $ from "jquery"
import Chartist from "chartist"
import Hogan from "hogan.js"
import PlanPageDataModel from "../plan_page_data_model"
import PlanPageViewModel from "../plan_page_view_model"
// import {ForIE} from "../ie"

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
    // nudge data are intentionally excluded from STATE_FROM_SERVER because they are not state,
    // they do not change but instead are static and fixed, displayed only.
    this.dataForNudgeByActivityType = window.NUDGES_BY_ACTIVITY_TYPE
    this.resetCurrentlySelectedActivityType()
  }

  connect() {
    this.planPageViewModel = new PlanPageViewModel(this.element)
    this.initDataFromDom()
    this.chartInteractivityEntryPoints = [
      this.initInteractivityForChartByTechnicalArea.bind(this),
      this.initInteractivityForChartByActivityType.bind(this),
    ]
    this.initBarChart()
    this.renderNudgeForTechnicalAreas()
    this.initActivityCountButton()
    // console.log("plan.connect: this.activityIds.length: ", (this.activityIds || []).length)
    this.initEventListeners()
  }

  resetCurrentlySelectedActivityType() {
    this.currentlySelectedActivityType = null
  }

  initDataFromDom() {
    this.term = parseInt(this.data.get("term"))
    this.nudgeSelectors  = JSON.parse(this.data.get("nudgeSelectors")) // expects an array of strings
    this.nudgeContentSelectors = JSON.parse(this.data.get("nudgeContentSelectors")) // expects an array of strings
    this.nudgeContentZeroSelector = this.data.get("nudgeContentZeroSelector") // expects a string
    this.nudgeTemplateSelector = this.data.get("nudgeTemplateSelector") // expects a string
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

  initActivityCountButton() {
    $(".activity-count-circle").on('click', () => {
      this.clickActivityCountButton()
    })
  }

  clickActivityCountButton() {
    $("#activity-list-by-type-container").hide()
    $(".technical-area-container").show()
    this.resetCurrentlySelectedActivityType()
    this.renderNudge()
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
        // show multiples of 10
        labelInterpolationFnc: function (value, index) {
          return value % 10 == 0  ? value: null;
        }
      },
    };
    this.charts[this.currentChartIndex] = new Chartist.Bar(this.chartSelectors[this.currentChartIndex], data, options);
    this.charts[this.currentChartIndex].on('created', () => {
      this.chartInteractivityEntryPoints[this.currentChartIndex]()
      this.fixesForIE()
    })
  }

  updateChart() {
    this.charts[this.currentChartIndex].update()
  }

  renderNudgeForTechnicalAreas() {
    const currentNudgeEl = this.nudgeSelectors[this.currentChartIndex]
    const currentNudgeTplSelector = this.nudgeContentSelectors[ this.term === 500 ? 1: 0]
    const nudgeHtmlContent = $(currentNudgeTplSelector).html()
    $(currentNudgeEl).empty().html(nudgeHtmlContent)
  }

  getNextMultipleOfTenForSeries(seriesArray) {
    const maxInt = Math.max(...seriesArray)
    const currentMultipleOfTen = Math.floor(maxInt / 10)
    return (currentMultipleOfTen + 1) * 10
  }

  // TODO: modify this to use PlanPageViewModel events instead?
  handleChartHideShow(event) {
    const {target: selectedTab} = event
    const zeroBasedTabIndex = $(selectedTab).parents("ul").find("a").index(selectedTab)
    this.currentChartIndex = zeroBasedTabIndex
    this.initBarChart()
  }

  initInteractivityForChartByTechnicalArea() {
    // query for bar segments only within the selector of the current chart
    $("line.ct-bar", this.chartSelectors[this.currentChartIndex]).each((segmentIndex, el) => {
      let $elBarSegment = $(el)
      this.initClickHandlerForChartByTechnicalArea($elBarSegment, segmentIndex)
      this.initTooltipForSegmentOfChartByTechnicalArea($elBarSegment, segmentIndex)
    })
  }

  initClickHandlerForChartByTechnicalArea($elBarSegment, index) {
    if (index > 0) {
      $($elBarSegment).on('click', () => {
        $("#activity-list-by-type-container").hide()
        $('.technical-area-container').hide()
        // NB: index is zero-based, but the target is 1-based, which is why +1.
        $(`#technical-area-${index + 1}`).show()
      })
    }
  }

  initTooltipForSegmentOfChartByTechnicalArea($elBarSegment, index) {
    // NB: index is zero-based, but the target is 1-based, which is why +1.
    let $elTitle = $(`#technical-area-${index + 1}`)
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
        // avoid click on the already selected chart segment re-presenting the same content
        if (this.currentlySelectedActivityType !== segmentIndex) {
          this.currentlySelectedActivityType = segmentIndex
          this.renderNudgeForActivityType()
        }
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

  renderNudge() {
    this.renderNudgeForActivityType()
  }

  renderNudgeForActivityType() {
    const indexOfActivityType = this.currentlySelectedActivityType
    const currentActivityCount = this.countByActivityType(indexOfActivityType)
    if (!indexOfActivityType || !(currentActivityCount >= 1)) {
      return this.renderNudgeZeroForActivityType()
    }

    const nudgeData = window.NUDGES_BY_ACTIVITY_TYPE[indexOfActivityType]
    const listItems = this.getListItemsForNudge(nudgeData, indexOfActivityType)
    const templateData = {
      activity_type: nudgeData["activity_type_name"],
      listItems: listItems.map(itemText => {
        return {item: itemText}
      })
    }

    const currentNudgeTplSelector = this.nudgeTemplateSelector
    const nudgeHtmlContent = $(currentNudgeTplSelector).html()
    const compiledTemplate = Hogan.compile(nudgeHtmlContent)
    const renderedContent = compiledTemplate.render(templateData)

    const currentNudgeEl = this.nudgeSelectors[this.currentChartIndex]
    $(currentNudgeEl).children().fadeOut(() => {
      $(currentNudgeEl).empty().html(renderedContent).fadeIn()
    })
  }

  renderNudgeZeroForActivityType() {
    const nudgeContentZeroSelector = this.nudgeContentZeroSelector
    const nudgeZeroContent = $(nudgeContentZeroSelector).html()
    const nudgeElByActivityType = this.nudgeSelectors[1] // 1 is for activity type tab
    $(nudgeElByActivityType).children().fadeOut(() => {
      $(nudgeElByActivityType).empty().html(nudgeZeroContent).fadeIn(() => {
        this.sizeTheSvgForIE()
      })
    })
  }

  getListItemsForNudge(nudgeData, selectedActivityTypeIndex) {
    const thresholdA = nudgeData["threshold_a"]
    const thresholdB = nudgeData["threshold_b"]
    const currentActivityCount = this.countByActivityType(selectedActivityTypeIndex)
    let indexForThreshold = this.getIndexForThreshold(currentActivityCount, thresholdA, thresholdB)
    const contentKey = ["content_for_a", "content_for_b", "content_for_c"][indexForThreshold]
    return nudgeData[contentKey].split("\n")
  }

  getIndexForThreshold(currentActivityCount, thresholdA, thresholdB) {
    if (thresholdA && thresholdB) {
      return this.getIndexForThresholdOfTwo(currentActivityCount, thresholdA, thresholdB)
    } else {
      return this.getIndexForThresholdOfOne(currentActivityCount, thresholdA)
    }
  }

  getIndexForThresholdOfTwo(currentActivityCount, thresholdA, thresholdB) {
    if (currentActivityCount < thresholdA) {
      return 0
    } else if (thresholdA <= currentActivityCount && currentActivityCount <= thresholdB) {
      return 1
    } else if (thresholdB < currentActivityCount) {
      return 2
    }
  }

  getIndexForThresholdOfOne(currentActivityCount, threshold) {
    if (currentActivityCount < threshold) {
      return 0
    } else if (threshold <= currentActivityCount) {
      return 1
    }
  }

  countByActivityType(selectedActivityTypeIndex) {
    const dataSet = this.chartDataSeries[this.currentChartIndex]
    return dataSet[selectedActivityTypeIndex]
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
    this.renderNudgeForActivityType()
  }

  decrementActivityCount(data) {
    this.decrementActivityCountCircleUI()
    this.decrementChartSegmentCountData(data)
    this.updateChart()
    this.renderNudgeForActivityType()
  }

  incrementActivityCountCircleUI() {
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

  //
  // The problem: needed a method to detect IE 10 and 11 for the purpose of working around an IE-specific
  //   issue, namely what the offsetTheChartSegmentLabelsForIE method addresses.
  //
  // Attempted solutions: First I tried to use Modernizr https://modernizr.com/ to take a
  //   feature-detection approach to working around the issue (as opposed to browser detection, which is not as
  //   good as a feature detection approach). At the time I tried it, Modernizr offered no detector for CSS transforms
  //   for SVG. The closest thing I found was this issue on the Modernizr repo which is still
  //   open/unmerged/unresolved: https://github.com/Modernizr/Modernizr/issues/1985
  //   Also looked into 3rd party libraries to handle this, most of which check the user agent string which is known to
  //   be an imperfect method, and would have required us to add yet another 3rd party library which we would rather avoid anyways.
  //
  // The solution: a browser detection technique via `document.documentMode` which is present on
  //   MS Internet Explorer 6 - 11 which is sufficient for this purpose. We actually just wanted to target IE 10-11
  //  but this is fine: its a simple and reliable dection method and does not require the addition of any additional code/libraries.
  //
  isIE() {
    return !!document.documentMode
  }

  //
  // The problem: IE does not support CSS transforms on SVG elements, which is what we used to get those
  //   bar chart segment labels rendered at a 45º angle in modern web browsers. That does not work in IE 10/11.
  //
  // Attempted solutions: tried to do this in CSS which would have been better and easier with the IE-specific
  //  stylesheet that we already have, but could not get these offsets to take effect via CSS for IE.
  //
  // The solution: In conjunction with the writing mode change in the IE-specific stylesheet to render these
  //   elements sideways at 90º, apply X and Y offsets here via JavaScript to the SVG nodes (TEXT nodes in IE).
  //   The offsets are arbitrary, just what aligned with the bar chart segments in IE 11 and looked decent on IE 11.
  //
  offsetTheChartSegmentLabelsForIE() {
    if (!this.isIE()) {
      return
    }

    $(".ct-label.ct-horizontal", this.chartSelectors[this.currentChartIndex]).each((i, el) => {
      const offsetX = 15
      const offsetY = 12
      const $el = $(el)
      const curXcoord = parseInt($el.attr("x"))
      const curYcoord = parseInt($el.attr("y"))
      $el.attr("x", curXcoord + offsetX).attr("y", curYcoord - offsetY)
    })
  }

  //
  // The problem: IE does not support CSS transforms on SVG elements
  //
  // The solution: Set the SVG PATH node's transform attribute via JS
  //
  sizeTheSvgForIE() {
    if (!this.isIE()) {
      return
    }

    $(".ico-bar-chart svg path", this.element).attr("transform", "scale(2.5)")
  }

  fixesForIE() {
    this.sizeTheSvgForIE()
    this.offsetTheChartSegmentLabelsForIE()
  }
}
