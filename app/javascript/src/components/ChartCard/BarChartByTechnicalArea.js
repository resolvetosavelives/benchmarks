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
  getPlanDiseases,
  getPlanChartLabels,
  getSelectedChartTabIndex,
  getSelectedTechnicalAreaId,
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
      series: matrixOfActionCountsByTechnicalAreaAndDisease,
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
          return value % 10 == 0 ? value : null
        },
      },
    }
    return {
      data,
      options,
    }
  }

  getNextMultipleOfTenForSeries(seriesArray) {
    const maxInt = Math.max(...seriesArray)
    const currentMultipleOfTen = Math.floor(maxInt / 10)
    return (currentMultipleOfTen + 1) * 10
  }

  initInteractivityForChart() {
    const planDiseases = this.props.planDiseases
    const dispatch = this.props.dispatch
    const countActionsByTechnicalArea = this.props.countActionsByTechnicalArea
    const matrixOfActionCountsByTechnicalAreaAndDisease = this.props
      .matrixOfActionCountsByTechnicalAreaAndDisease
    const technicalAreas = this.props.technicalAreas
    const chartistGraph = this.chartistGraphInstance
    const selectedTechnicalAreaId = this.props.selectedTechnicalAreaId
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    const series = [$(".ct-series-a .ct-bar", domNode)]

    planDiseases.forEach((disease, i) => {
      const seriesLetter = String.fromCharCode("b".charCodeAt(0) + i)
      series.push($(`.ct-series-${seriesLetter} .ct-bar`, domNode))
    })

    series.forEach((series) => {
      series.removeClass("ct-deselected")
    })

    this.cleanupTooltipsFromPreviousRender()
    offsetTheChartSegmentLabelsForIE(domNode)

    for (
      let technicalIndex = 0;
      technicalIndex < countActionsByTechnicalArea.length;
      technicalIndex++
    ) {
      if (
        selectedTechnicalAreaId &&
        technicalIndex !== selectedTechnicalAreaId
      ) {
        series.forEach((barSegments, seriesIndex) => {
          $(series[seriesIndex][technicalIndex]).addClass("ct-deselected")
        })
      }

      this.initTooltipForSegmentOfChartByTechnicalArea(
        matrixOfActionCountsByTechnicalAreaAndDisease,
        technicalIndex,
        technicalAreas,
        series,
        planDiseases
      )
      this.initClickHandlerForChartByTechnicalArea(
        dispatch,
        technicalIndex,
        series
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
    matrixOfActionCountsByTechnicalAreaAndDisease,
    technicalIndex,
    technicalAreas,
    series,
    planDiseases
  ) {
    const nameOfTechnicalArea = technicalAreas[technicalIndex]
    const tooltipTitle = this.getTooltipHtmlContent(
      nameOfTechnicalArea,
      matrixOfActionCountsByTechnicalAreaAndDisease,
      technicalIndex,
      series,
      planDiseases
    )
    // const stackedBarEls = [$elBarSegmentA, $elBarSegmentB, $elBarSegmentC]
    series.forEach((_barSegments, seriesIndex) => {
      $(series[seriesIndex][technicalIndex])
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .attr("data-html", true)
        .tooltip({ container: ".plan-container" })
        .tooltip()

      this.tooltipNodesFromPreviousRender.push(
        $(series[seriesIndex][technicalIndex])
      )
    })
    // series.forEach(($elBarSegment) => {
    //   $elBarSegment
    //     .attr("title", tooltipTitle)
    //     .attr("data-toggle", "tooltip")
    //     .attr("data-html", true)
    //     .tooltip({ container: ".plan-container" })
    //     .tooltip()

    //   this.tooltipNodesFromPreviousRender.push($elBarSegment)
    // })
  }

  getTooltipCategoryDisplayName(category) {
    let displayName = ""

    if (category === "general") {
      displayName = "Health System"
    } else {
      displayName = "${category}-specific"
    }

    return displayName
  }

  getTooltipHtmlContent(
    nameOfTechnicalArea,
    matrixOfActionCountsByTechnicalAreaAndDisease,
    technicalIndex,
    series,
    planDiseases
  ) {
    const healthSystemCount =
      matrixOfActionCountsByTechnicalAreaAndDisease[0][technicalIndex]

    let sumOfCounts = healthSystemCount

    planDiseases.forEach((disease, i) => {
      sumOfCounts +=
        matrixOfActionCountsByTechnicalAreaAndDisease[i + 1][technicalIndex]
    })

    let tooltipHtml = `
        <strong>
          ${nameOfTechnicalArea.text}: ${sumOfCounts}
        </strong>
    `

    if (planDiseases.length > 0) {
      tooltipHtml += `
        <div>&nbsp;</div>
        <div>Health System: ${healthSystemCount}</div>
      `
    }

    planDiseases.forEach((disease, i) => {
      const diseaseCount =
        matrixOfActionCountsByTechnicalAreaAndDisease[i + 1][technicalIndex]
      tooltipHtml += `<div>${disease.display}-specific: ${diseaseCount}</div>`
    })

    return tooltipHtml
  }

  initClickHandlerForChartByTechnicalArea(dispatch, technicalIndex, series) {
    series.forEach((barSegments, seriesIndex) => {
      $(barSegments[seriesIndex][technicalIndex]).on("click", () => {
        dispatch(selectTechnicalArea(technicalIndex))
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
  planDiseases: PropTypes.array.isRequired,
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
    selectedChartTabIndex: getSelectedChartTabIndex(state),
    planDiseases: getPlanDiseases(state),
  }
}

export default connect(mapStateToProps)(BarChartByTechnicalArea)
