import React from "react"
import { connect } from "react-redux"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectTechnicalArea } from "../../config/actions"
import {
  countActionsByTechnicalArea,
  getAllActions,
  getAllTechnicalAreas,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getPlanChartLabels,
  getSelectedTechnicalAreaId,
  getUi,
} from "../../config/selectors"
import { offsetTheChartSegmentLabelsForIE } from "./ChartFixesForIE"

class BarChartByTechnicalArea extends React.Component {
  constructor(props) {
    super(props)
    this.tooltipNodesFromPreviousRender = []
  }

  render() {
    const chartLabels = this.props.chartLabels[0]
    const countActionsByTechnicalArea = this.props.countActionsByTechnicalArea
    const { data, options } = this.getBarChartOptions(
      countActionsByTechnicalArea,
      this.props.matrixOfActionCountsByTechnicalAreaAndDisease,
      chartLabels
    )
    this.updateChartSize()
    return (
      <div className="chart-container ct-chart-bar">
        <ChartistGraph
          data={data}
          options={options}
          type="Bar"
          ref={(ref) => {
            if (ref) this.chartistGraphInstance = ref
          }}
          listener={{ created: this.initInteractivityForChart.bind(this) }}
        />
      </div>
    )
  }

  componentDidMount() {
    window.addEventListener("resize", this.updateChartSize.bind(this))
    window.addEventListener(
      "orientationchange",
      this.updateChartSize.bind(this)
    )
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.updateChartSize.bind(this))
    window.removeEventListener(
      "orientationchange",
      this.updateChartSize.bind(this)
    )
  }

  // NB: the purpose of this method is to assist the chart in fitting into its container by simply calling chartist.update()
  //   this is needed in these cases:
  //   1) when selected tab is changed and chart re-renders, it will have been rendered too small due to having been in the hidden in the DOM
  //   2) when the size of the window is changed (primarily for desktop-style web browsers)
  //   3) when the orientation of the screen is changed thereby changing the size of the screen (primarily mobile-style web browsers: phones, tables, etc)
  updateChartSize() {
    setTimeout(() => {
      this.chartistGraphInstance.chartist.update()
      offsetTheChartSegmentLabelsForIE(
        this.chartistGraphInstance.chartist.container
      )
    }, 0)
  }

  getBarChartOptions(
    countActionsByTechnicalArea,
    matrixOfActionCountsByTechnicalAreaAndDisease,
    chartLabels
  ) {
    let data = {
      labels: chartLabels,
      series: this.calculateChartSeries(
        matrixOfActionCountsByTechnicalAreaAndDisease
      ),
    }
    const heightValue = this.getNextMultipleOfTenForSeries(
      countActionsByTechnicalArea
    )
    let options = {
      high: heightValue,
      low: 0,
      width: this.props.width,
      height: this.props.height,
      stackBars: true,
      axisY: {
        // show multiples of 10
        labelInterpolationFnc: function (value) {
          return value % 10 === 0 ? value : null
        },
      },
    }
    return {
      data,
      options,
    }
  }

  calculateChartSeries(matrixOfActionCountsByActionTypeAndDisease) {
    const matrix = [].concat(matrixOfActionCountsByActionTypeAndDisease)
    if (!this.props.ui.isInfluenzaShowing) {
      matrix[1] = matrix[1].map(() => 0)
    }
    if (!this.props.ui.isCholeraShowing) {
      matrix[2] = matrix[2].map(() => 0)
    }
    return matrix
  }

  getNextMultipleOfTenForSeries(seriesArray) {
    const maxInt = Math.max(...seriesArray)
    const currentMultipleOfTen = Math.floor(maxInt / 10)
    return (currentMultipleOfTen + 1) * 10
  }

  initInteractivityForChart() {
    const dispatch = this.props.dispatch
    const matrixOfActionCountsByTechnicalAreaAndDisease = this.props
      .matrixOfActionCountsByTechnicalAreaAndDisease
    const technicalAreas = this.props.technicalAreas
    const chartistGraph = this.chartistGraphInstance
    const selectedTechnicalAreaId = this.props.selectedTechnicalAreaId
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    const seriesA = $(".ct-series-a .ct-bar", domNode)
    const seriesB = $(".ct-series-b .ct-bar", domNode)
    const seriesC = $(".ct-series-c .ct-bar", domNode)
    seriesA.removeClass("ct-deselected")
    seriesB.removeClass("ct-deselected")
    seriesC.removeClass("ct-deselected")

    this.cleanupTooltipsFromPreviousRender()
    offsetTheChartSegmentLabelsForIE(domNode)

    for (let i = 0; i < technicalAreas.length; i++) {
      const objOfActionCounts = {
        general: matrixOfActionCountsByTechnicalAreaAndDisease[0][i],
        influenza: matrixOfActionCountsByTechnicalAreaAndDisease[1][i],
        cholera: matrixOfActionCountsByTechnicalAreaAndDisease[2][i],
      }
      const $elBarSegmentA = $(seriesA[i])
      const $elBarSegmentB = $(seriesB[i])
      const $elBarSegmentC = $(seriesC[i])
      if (
        selectedTechnicalAreaId &&
        technicalAreas[i].id !== selectedTechnicalAreaId
      ) {
        $elBarSegmentA.addClass("ct-deselected")
        $elBarSegmentB.addClass("ct-deselected")
        $elBarSegmentC.addClass("ct-deselected")
      }
      this.initTooltipForSegmentOfChartByTechnicalArea(
        technicalAreas[i],
        objOfActionCounts,
        $elBarSegmentA,
        $elBarSegmentB,
        $elBarSegmentC,
        i
      )
      this.initClickHandlerForChartByTechnicalArea(
        technicalAreas[i],
        dispatch,
        $elBarSegmentA,
        $elBarSegmentB,
        $elBarSegmentC
      )
    }
  }

  cleanupTooltipsFromPreviousRender() {
    for (const $tooltipEl of this.tooltipNodesFromPreviousRender) {
      $tooltipEl.tooltip("dispose")
    }
    this.tooltipNodesFromPreviousRender = []
  }

  initTooltipForSegmentOfChartByTechnicalArea(
    technicalArea,
    objOfActionCounts,
    $elBarSegmentA,
    $elBarSegmentB,
    $elBarSegmentC
  ) {
    const tooltipTitle = this.getTooltipHtmlContent(
      technicalArea,
      objOfActionCounts
    )
    const stackedBarEls = [$elBarSegmentA, $elBarSegmentB, $elBarSegmentC]
    stackedBarEls.forEach(($elBarSegment) => {
      $elBarSegment
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .attr("data-html", true)
        .tooltip({ container: ".plan-container" })
        .tooltip()

      this.tooltipNodesFromPreviousRender.push($elBarSegment)
    })
  }

  tooltipCategoryDisplayName(category) {
    let displayName = ""

    if (category === "general") {
      displayName = "Health System"
    } else {
      displayName = "${category}-specific"
    }

    return displayName
  }

  getTooltipHtmlContent(technicalArea, objOfActionCounts) {
    const sumOfCounts = Object.keys(objOfActionCounts).reduce(
      (sum, key) => sum + objOfActionCounts[key],
      0
    )
    let tooltipHtml = `<strong>${technicalArea.text}: ${sumOfCounts}</strong>`

    if (sumOfCounts > objOfActionCounts.general) {
      tooltipHtml += `<div>&nbsp;</div>`

      for (const category in objOfActionCounts) {
        if (this.props.ui[`is${category}Showing`]) {
          tooltipHtml += `<div>${this.tooltipCategoryDisplayName(category)}: ${
            objOfActionCounts[category]
          }</div>`
        }
      }
    }

    return tooltipHtml
  }

  initClickHandlerForChartByTechnicalArea(
    technicalArea,
    dispatch,
    $elBarSegmentA,
    $elBarSegmentB,
    $elBarSegmentC
  ) {
    const stackedBarEls = [$elBarSegmentA, $elBarSegmentB, $elBarSegmentC]
    stackedBarEls.forEach(($elBarSegment) => {
      $elBarSegment.on("click", () => {
        dispatch(selectTechnicalArea(technicalArea.id))
      })
    })
  }
}

BarChartByTechnicalArea.propTypes = {
  width: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  technicalAreas: PropTypes.array.isRequired,
  chartLabels: PropTypes.array.isRequired,
  allActions: PropTypes.array.isRequired,
  dispatch: PropTypes.func,
  countActionsByTechnicalArea: PropTypes.array.isRequired,
  matrixOfActionCountsByTechnicalAreaAndDisease: PropTypes.array.isRequired,
  selectedTechnicalAreaId: PropTypes.number,
  ui: PropTypes.object,
}

const mapStateToProps = (state /*, ownProps*/) => {
  return {
    technicalAreas: getAllTechnicalAreas(state),
    chartLabels: getPlanChartLabels(state),
    allActions: getAllActions(state),
    matrixOfActionCountsByTechnicalAreaAndDisease: getMatrixOfActionCountsByTechnicalAreaAndDisease(
      state
    ),
    countActionsByTechnicalArea: countActionsByTechnicalArea(state),
    selectedTechnicalAreaId: getSelectedTechnicalAreaId(state),
    ui: getUi(state),
  }
}

export default connect(mapStateToProps)(BarChartByTechnicalArea)
