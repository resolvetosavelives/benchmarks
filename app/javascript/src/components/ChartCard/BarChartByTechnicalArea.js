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
} from "../../config/selectors"
import BarChartLegend from "./BarChartLegend"

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
    seriesA.removeClass("ct-deselected")
    seriesB.removeClass("ct-deselected")

    this.cleanupTooltipsFromPreviousRender()

    for (let i = 0; i < technicalAreas.length; i++) {
      const objOfActionCounts = {
        general: matrixOfActionCountsByTechnicalAreaAndDisease[0][i],
        influenza: matrixOfActionCountsByTechnicalAreaAndDisease[1][i],
      }
      const $elBarSegmentA = $(seriesA[i])
      const $elBarSegmentB = $(seriesB[i])
      if (
        selectedTechnicalAreaId &&
        technicalAreas[i].id !== selectedTechnicalAreaId
      ) {
        $elBarSegmentA.addClass("ct-deselected")
        $elBarSegmentB.addClass("ct-deselected")
      }
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
    $elBarSegmentB
  ) {
    const tooltipTitle = this.getTooltipHtmlContent(
      technicalArea,
      objOfActionCounts
    )
    const stackedBarEls = [$elBarSegmentA, $elBarSegmentB]
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
    const stackedBarEls = [$elBarSegmentA, $elBarSegmentB]
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
  }
}

export default connect(mapStateToProps)(BarChartByTechnicalArea)