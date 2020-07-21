import React from "react"
import { connect } from "react-redux"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectTechnicalArea } from "../../config/actions"
import {
  getAllActions,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getPlanActionIds,
} from "../../config/selectors"
import BarChartLegend from "./BarChartLegend"

class BarChartByTechnicalArea extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    const chartLabels = this.props.chartLabels[0]
    const { data, options } = this.getBarChartOptions(
      this.props.matrixOfActionCountsByTechnicalAreaAndDisease,
      chartLabels
    )
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
        <BarChartLegend />
      </div>
    )
  }

  getBarChartOptions(
    matrixOfActionCountsByTechnicalAreaAndDisease,
    chartLabels
  ) {
    let data = {
      labels: chartLabels,
      series: matrixOfActionCountsByTechnicalAreaAndDisease,
    }
    const heightValue = this.getNextMultipleOfTenForSeries(
      matrixOfActionCountsByTechnicalAreaAndDisease[0]
    )
    let options = {
      high: heightValue,
      low: 0,
      width: this.props.width,
      height: this.props.height,
      axisY: {
        // show multiples of 10
        labelInterpolationFnc: function (value) {
          return value % 10 == 0 ? value : null
        },
      },
      stackBars: true,
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
    const dispatch = this.props.dispatch
    const matrixOfActionCountsByTechnicalAreaAndDisease = this.props
      .matrixOfActionCountsByTechnicalAreaAndDisease
    const technicalAreas = this.props.technicalAreas
    const chartistGraph = this.chartistGraphInstance
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    const seriesA = $(".ct-series-a .ct-bar", domNode)
    const seriesB = $(".ct-series-b .ct-bar", domNode)
    for (let i = 0; i < technicalAreas.length; i++) {
      const objOfActionCounts = {
        general: matrixOfActionCountsByTechnicalAreaAndDisease[0][i],
        influenza: matrixOfActionCountsByTechnicalAreaAndDisease[1][i],
      }
      const $elBarSegmentA = $(seriesA[i])
      const $elBarSegmentB = $(seriesB[i])
      this.initTooltipForSegmentOfChartByTechnicalArea(
        technicalAreas[i],
        objOfActionCounts,
        $elBarSegmentA,
        $elBarSegmentB,
        i
      )
      this.initClickHandlerForChartByTechnicalArea(
        technicalAreas[i],
        dispatch,
        $elBarSegmentA,
        $elBarSegmentB
      )
    }
  }

  initTooltipForSegmentOfChartByTechnicalArea(
    technicalArea,
    objOfActionCounts,
    $elBarSegmentA,
    $elBarSegmentB
  ) {
    const tooltipTitle = this.getTooltipHtmlContent(
      technicalArea,
      objOfActionCounts
    )
    const stackedBarEls = [$elBarSegmentA, $elBarSegmentB]
    stackedBarEls.forEach((elBarSegment) => {
      elBarSegment
        .attr("title", tooltipTitle)
        .attr("data-html", true)
        .attr("data-toggle", "tooltip")
        .tooltip({ container: ".plan-container" })
        .tooltip()
    })
  }

  getTooltipHtmlContent(technicalArea, objOfActionCounts) {
    const sumOfCounts = objOfActionCounts.general + objOfActionCounts.influenza
    let tooltipHtml = `
        <strong>
          ${technicalArea.text}: ${sumOfCounts}
        </strong>
    `
    if (objOfActionCounts.influenza > 0) {
      tooltipHtml = `${tooltipHtml}
        <div>&nbsp;</div>
        <div>Health System: ${objOfActionCounts.general}</div>
        <div>Influenza-specific: ${objOfActionCounts.influenza}</div>
      `
    }
    return tooltipHtml
  }

  initClickHandlerForChartByTechnicalArea(
    technicalArea,
    dispatch,
    $elBarSegmentA,
    $elBarSegmentB
  ) {
    $elBarSegmentA.on("click", () => {
      dispatch(selectTechnicalArea(technicalArea.id))
    })
    $elBarSegmentB.on("click", () => {
      dispatch(selectTechnicalArea(technicalArea.id))
    })
  }
}

BarChartByTechnicalArea.propTypes = {
  width: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  technicalAreas: PropTypes.array.isRequired,
  chartLabels: PropTypes.array.isRequired,
  planActionIds: PropTypes.array.isRequired,
  allActions: PropTypes.array.isRequired,
  dispatch: PropTypes.func,
  matrixOfActionCountsByTechnicalAreaAndDisease: PropTypes.array.isRequired,
}

const mapStateToProps = (state /*, ownProps*/) => {
  return {
    technicalAreas: state.technicalAreas,
    chartLabels: state.planChartLabels,
    planActionIds: getPlanActionIds(state),
    allActions: getAllActions(state),
    matrixOfActionCountsByTechnicalAreaAndDisease: getMatrixOfActionCountsByTechnicalAreaAndDisease(
      state
    ),
  }
}

export default connect(mapStateToProps)(BarChartByTechnicalArea)
