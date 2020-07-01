import React from "react"
import { connect } from "react-redux"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectTechnicalArea } from "../../config/actions"
import {
  getAllActions,
  getPlanActionIds,
  countActionsByTechnicalArea,
} from "../../config/selectors"

class BarChartByTechnicalArea extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    const chartLabels = this.props.chartLabels[0]
    const { data, options } = this.getBarChartOptions(
      this.props.countActionsByTechnicalArea,
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
      </div>
    )
  }

  // TODO: refactor this and methods like it that perform non-React DOM operations/augmentation/manipulation to a module
  getBarChartOptions(chartDataSeries, chartLabels) {
    const dataSet = chartDataSeries
    let data = {
      labels: chartLabels,
      series: [dataSet],
    }
    const heightValue = this.getNextMultipleOfTenForSeries(dataSet)
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
    const countActionsByTechnicalArea = this.props.countActionsByTechnicalArea
    const technicalAreas = this.props.technicalAreas
    const chartistGraph = this.chartistGraphInstance
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    $("line.ct-bar", domNode).each((segmentIndex, el) => {
      let $elBarSegment = $(el)
      this.initTooltipForSegmentOfChartByTechnicalArea(
        $elBarSegment,
        segmentIndex,
        countActionsByTechnicalArea[segmentIndex]
      )
      this.initClickHandlerForChartByTechnicalArea(
        $elBarSegment,
        technicalAreas[segmentIndex],
        dispatch
      )
    })
  }

  initTooltipForSegmentOfChartByTechnicalArea(
    $elBarSegment,
    index,
    countActions
  ) {
    const tooltipTitle = `${this.props.technicalAreas[index].text}: ${countActions}`
    $($elBarSegment)
      .attr("title", tooltipTitle)
      .attr("data-toggle", "tooltip")
      .tooltip({ container: ".plan-container" })
      .tooltip()
  }

  initClickHandlerForChartByTechnicalArea(
    $elBarSegment,
    technicalArea,
    dispatch
  ) {
    $elBarSegment.on("click", () => {
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
  countActionsByTechnicalArea: PropTypes.array.isRequired,
}

const mapStateToProps = (state /*, ownProps*/) => {
  return {
    technicalAreas: state.technicalAreas,
    chartLabels: state.planChartLabels,
    planActionIds: getPlanActionIds(state),
    allActions: getAllActions(state),
    countActionsByTechnicalArea: countActionsByTechnicalArea(state),
  }
}

export default connect(mapStateToProps)(BarChartByTechnicalArea)
