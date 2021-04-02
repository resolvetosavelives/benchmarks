import React from "react"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectActionType } from "../../config/actions"
import { offsetTheChartSegmentLabelsForIE } from "./ChartFixesForIE"

class BarChart extends React.Component {
  constructor(props) {
    super(props)
    this.chartLabels = this.props.chartLabels[1]
    this.tooltipNodesFromPreviousRender = []
  }

  render() {
    this.updateChartSize()
    return (
      <div className="chart-container ct-chart-bar">
        <ChartistGraph
          data={this.chartData()}
          options={this.chartOptions()}
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

  chartData() {
    const matrix = [].concat(
      this.props.matrixOfActionCountsByActionTypeAndDisease
    )
    if (!this.props.ui.isInfluenzaShowing) {
      matrix[1] = matrix[1].map(() => 0)
    }
    if (!this.props.ui.isCholeraShowing) {
      matrix[2] = matrix[2].map(() => 0)
    }
    if (!this.props.ui.isEbolaShowing) {
      matrix[3] = matrix[3].map(() => 0)
    }

    return {
      labels: this.chartLabels,
      series: matrix,
    }
  }

  chartOptions() {
    const heightValue = this.getNextMultipleOfTenForSeries(
      this.props.countActionsByActionType
    )
    return {
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
  }

  getNextMultipleOfTenForSeries(seriesArray) {
    const maxInt = Math.max(...seriesArray)
    const currentMultipleOfTen = Math.floor(maxInt / 10)
    return (currentMultipleOfTen + 1) * 10
  }

  initInteractivityForChart() {
    const dispatch = this.props.dispatch
    const countActionsByActionType = this.props.countActionsByActionType
    const matrixOfActionCountsByActionTypeAndDisease = this.props
      .matrixOfActionCountsByActionTypeAndDisease
    const chartistGraph = this.chartistGraphInstance
    const selectedActionTypeOrdinal = this.props.selectedActionTypeOrdinal
    const chartLabels = this.chartLabels
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    const seriesA = $(".ct-series-a .ct-bar", domNode)
    const seriesB = $(".ct-series-b .ct-bar", domNode)
    const seriesC = $(".ct-series-c .ct-bar", domNode)
    const seriesD = $(".ct-series-d .ct-bar", domNode)
    seriesA.removeClass("ct-deselected")
    seriesB.removeClass("ct-deselected")
    seriesC.removeClass("ct-deselected")
    seriesD.removeClass("ct-deselected")

    this.cleanupTooltipsFromPreviousRender()
    offsetTheChartSegmentLabelsForIE(domNode)

    for (let i = 0; i < countActionsByActionType.length; i++) {
      const objOfActionCounts = {
        general: matrixOfActionCountsByActionTypeAndDisease[0][i],
        influenza: matrixOfActionCountsByActionTypeAndDisease[1][i],
        cholera: matrixOfActionCountsByActionTypeAndDisease[2][i],
        ebola: matrixOfActionCountsByActionTypeAndDisease[3][i],
      }
      const $elBarSegmentA = $(seriesA[i])
      const $elBarSegmentB = $(seriesB[i])
      const $elBarSegmentC = $(seriesC[i])
      const $elBarSegmentD = $(seriesD[i])
      if (selectedActionTypeOrdinal && i !== selectedActionTypeOrdinal - 1) {
        $elBarSegmentA.addClass("ct-deselected")
        $elBarSegmentB.addClass("ct-deselected")
        $elBarSegmentC.addClass("ct-deselected")
        $elBarSegmentD.addClass("ct-deselected")
      }
      this.initTooltipForSegmentOfChart(
        objOfActionCounts,
        chartLabels[i],
        $elBarSegmentA,
        $elBarSegmentB,
        $elBarSegmentC,
        $elBarSegmentD
      )
      this.initClickHandlerForChart(
        dispatch,
        i,
        $elBarSegmentA,
        $elBarSegmentB,
        $elBarSegmentC,
        $elBarSegmentD
      )
    }
  }

  cleanupTooltipsFromPreviousRender() {
    for (const $tooltipEl of this.tooltipNodesFromPreviousRender) {
      $tooltipEl.tooltip("dispose")
    }
    this.tooltipNodesFromPreviousRender = []
  }

  initTooltipForSegmentOfChart(
    objOfActionCounts,
    nameOfActionType,
    $elBarSegmentA,
    $elBarSegmentB,
    $elBarSegmentC,
    $elBarSegmentD
  ) {
    const tooltipTitle = this.getTooltipHtmlContent(
      nameOfActionType,
      objOfActionCounts
    )
    const stackedBarEls = [
      $elBarSegmentA,
      $elBarSegmentB,
      $elBarSegmentC,
      $elBarSegmentD,
    ]
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

  getTooltipHtmlContent(nameOfActionType, objOfActionCounts) {
    const sumOfCounts =
      objOfActionCounts.general +
      objOfActionCounts.influenza +
      objOfActionCounts.cholera
    objOfActionCounts.ebola

    let tooltipHtml = `<strong> ${nameOfActionType}: ${sumOfCounts} </strong>`
    if (sumOfCounts > objOfActionCounts.general) {
      tooltipHtml += `<div>&nbsp;</div><div>Health System: ${objOfActionCounts.general}</div>`
    }
    if (objOfActionCounts.influenza > 0 && this.props.ui.isInfluenzaShowing) {
      tooltipHtml += `<div>Influenza-specific: ${objOfActionCounts.influenza}</div>`
    }
    if (objOfActionCounts.cholera > 0 && this.props.ui.isCholeraShowing) {
      tooltipHtml += `<div>Cholera-specific: ${objOfActionCounts.cholera}</div>`
    }
    if (objOfActionCounts.ebola > 0 && this.props.ui.isEbolaShowing) {
      tooltipHtml += `<div>Ebola-specific: ${objOfActionCounts.ebola}</div>`
    }

    return tooltipHtml
  }

  initClickHandlerForChart(
    dispatch,
    segmentIndex,
    $elBarSegmentA,
    $elBarSegmentB,
    $elBarSegmentC,
    $elBarSegmentD
  ) {
    const stackedBarEls = [
      $elBarSegmentA,
      $elBarSegmentB,
      $elBarSegmentC,
      $elBarSegmentD,
    ]
    stackedBarEls.forEach(($elBarSegment) => {
      $elBarSegment.on("click", () => {
        dispatch(selectActionType(segmentIndex))
      })
    })
  }
}

BarChart.propTypes = {
  width: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  chartLabels: PropTypes.array.isRequired,
  planActionIds: PropTypes.array.isRequired,
  allActions: PropTypes.array.isRequired,
  dispatch: PropTypes.func,
  countActionsByActionType: PropTypes.array.isRequired,
  matrixOfActionCountsByActionTypeAndDisease: PropTypes.array.isRequired,
  selectedActionTypeOrdinal: PropTypes.number,
  ui: PropTypes.object,
}

export default BarChart
