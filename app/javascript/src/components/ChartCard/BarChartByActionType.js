import React from "react"
import { connect } from "react-redux"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectActionType } from "../../config/actions"
import {
  countActionsByActionType,
  getAllActions,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getPlanActionIds,
  getPlanChartLabels,
  getPlanDiseases,
  getSelectedActionTypeOrdinal,
  getSelectedChartTabIndex,
} from "../../config/selectors"
import { offsetTheChartSegmentLabelsForIE } from "./ChartFixesForIE"

class BarChartByActionType extends React.Component {
  constructor(props) {
    super(props)
    this.chartLabels = this.props.chartLabels[1]
    this.tooltipNodesFromPreviousRender = []
  }

  render() {
    const { data, options } = this.getBarChartOptions(
      this.props.countActionsByActionType,
      this.props.matrixOfActionCountsByActionTypeAndDisease,
      this.chartLabels
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
    countActionsByActionType,
    matrixOfActionCountsByActionTypeAndDisease,
    chartLabels
  ) {
    let data = {
      labels: chartLabels,
      series: matrixOfActionCountsByActionTypeAndDisease,
    }
    const heightValue = this.getNextMultipleOfTenForSeries(
      countActionsByActionType
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
    const countActionsByActionType = this.props.countActionsByActionType
    const matrixOfActionCountsByActionTypeAndDisease = this.props
      .matrixOfActionCountsByActionTypeAndDisease
    const chartistGraph = this.chartistGraphInstance
    const selectedActionTypeOrdinal = this.props.selectedActionTypeOrdinal
    const chartLabels = this.chartLabels
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
      let actionIndex = 0;
      actionIndex < countActionsByActionType.length;
      actionIndex++
    ) {
      if (
        selectedActionTypeOrdinal &&
        actionIndex !== selectedActionTypeOrdinal - 1
      ) {
        series.forEach((barSegments, seriesIndex) => {
          $(series[seriesIndex][actionIndex]).addClass("ct-deselected")
        })
      }

      this.initTooltipForSegmentOfChart(
        matrixOfActionCountsByActionTypeAndDisease,
        actionIndex,
        chartLabels,
        series,
        planDiseases
      )
      this.initClickHandlerForChart(dispatch, actionIndex, series)
    }
  }

  cleanupTooltipsFromPreviousRender() {
    for (const $tooltipEl of this.tooltipNodesFromPreviousRender) {
      $tooltipEl.tooltip("dispose")
    }
    this.tooltipNodesFromPreviousRender = []
  }

  initTooltipForSegmentOfChart(
    matrixOfActionCountsByActionTypeAndDisease,
    actionIndex,
    chartLabels,
    series,
    planDiseases
  ) {
    const nameOfActionType = chartLabels[actionIndex]
    const tooltipTitle = this.getTooltipHtmlContent(
      nameOfActionType,
      matrixOfActionCountsByActionTypeAndDisease,
      actionIndex,
      series,
      planDiseases
    )
    series.forEach((_barSegments, seriesIndex) => {
      $(series[seriesIndex][actionIndex])
        .attr("title", tooltipTitle)
        .attr("data-toggle", "tooltip")
        .attr("data-html", true)
        .tooltip({ container: ".plan-container" })
        .tooltip()

      this.tooltipNodesFromPreviousRender.push(
        $(series[seriesIndex][actionIndex])
      )
    })
  }

  getTooltipHtmlContent(
    nameOfActionType,
    matrixOfActionCountsByActionTypeAndDisease,
    actionIndex,
    series,
    planDiseases
  ) {
    const healthSystemCount =
      matrixOfActionCountsByActionTypeAndDisease[0][actionIndex]

    let sumOfCounts = healthSystemCount

    planDiseases.forEach((disease, i) => {
      sumOfCounts +=
        matrixOfActionCountsByActionTypeAndDisease[i + 1][actionIndex]
    })

    let tooltipHtml = `
        <strong>
          ${nameOfActionType}: ${sumOfCounts}
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
        matrixOfActionCountsByActionTypeAndDisease[i + 1][actionIndex]
      tooltipHtml += `<div>${disease.display}-specific: ${diseaseCount}</div>`
    })

    return tooltipHtml
  }

  initClickHandlerForChart(dispatch, actionIndex, series) {
    series.forEach((barSegments, seriesIndex) => {
      $(barSegments[seriesIndex][actionIndex]).on("click", () => {
        dispatch(selectActionType(actionIndex))
      })
    })
  }
}

BarChartByActionType.propTypes = {
  width: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  chartLabels: PropTypes.array.isRequired,
  planActionIds: PropTypes.array.isRequired,
  allActions: PropTypes.array.isRequired,
  dispatch: PropTypes.func,
  countActionsByActionType: PropTypes.array.isRequired,
  matrixOfActionCountsByActionTypeAndDisease: PropTypes.array.isRequired,
  selectedActionTypeOrdinal: PropTypes.number,
  planDiseases: PropTypes.array.isRequired,
}

const mapStateToProps = (state /*, ownProps*/) => {
  return {
    chartLabels: getPlanChartLabels(state),
    planActionIds: getPlanActionIds(state),
    allActions: getAllActions(state),
    countActionsByActionType: countActionsByActionType(state),
    matrixOfActionCountsByActionTypeAndDisease: getMatrixOfActionCountsByActionTypeAndDisease(
      state
    ),
    selectedActionTypeOrdinal: getSelectedActionTypeOrdinal(state),
    selectedChartTabIndex: getSelectedChartTabIndex(state),
    planDiseases: getPlanDiseases(state),
  }
}

export default connect(mapStateToProps)(BarChartByActionType)
