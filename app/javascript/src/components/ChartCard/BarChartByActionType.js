import React from "react"
import { connect } from "react-redux"
import ChartistGraph from "react-chartist"
import PropTypes from "prop-types"
import $ from "jquery"
import { selectActionType } from "../../config/actions"
import { countActionsByActionType } from "../../config/selectors"
import BarChartLegend from "./BarChartLegend"

class BarChartByActionType extends React.Component {
  constructor(props) {
    super(props)
    if (!this.chartistGraphInstance) {
      this.chartistGraphInstance = null // will be a ref to the chartist instance
    }
    this.chartLabels = this.props.chartLabels[1]
  }

  render() {
    const countActionsByActionType = this.props.countActionsByActionType
    const { data, options } = this.getBarChartOptions(
      countActionsByActionType,
      this.chartLabels
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
    const countActionsByActionType = this.props.countActionsByActionType
    const chartistGraph = this.chartistGraphInstance
    chartistGraph.chartist.detach()
    const domNode = chartistGraph.chart
    $("line.ct-bar", domNode).each((segmentIndex, el) => {
      let $elBarSegment = $(el)
      this.initTooltipForSegmentOfChart(
        $elBarSegment,
        segmentIndex,
        countActionsByActionType[segmentIndex]
      )
      this.initClickHandlerForChart($elBarSegment, segmentIndex, dispatch)
    })
  }

  initTooltipForSegmentOfChart($elBarSegment, index, countActions) {
    const tooltipTitle = `${this.chartLabels[index]}: ${countActions}`
    $($elBarSegment)
      .attr("title", tooltipTitle)
      .attr("data-toggle", "tooltip")
      .tooltip({ container: ".plan-container" })
      .tooltip()
  }

  initClickHandlerForChart($elBarSegment, segmentIndex, dispatch) {
    $elBarSegment.on("click", () => {
      dispatch(selectActionType(segmentIndex))
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
  countActionsByActionType: PropTypes.array,
}

const mapStateToProps = (state /*, ownProps*/) => {
  return {
    chartLabels: state.planChartLabels,
    planActionIds: state.planActionIds,
    allActions: state.allActions,
    countActionsByActionType: countActionsByActionType(state),
  }
}

export default connect(mapStateToProps)(BarChartByActionType)
