import React from "react"
import { connect } from "react-redux"
import PropTypes from "prop-types"
import BarChart from "./BarChart"
import {
  countActionsByActionType,
  getAllActions,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getPlanActionIds,
  getPlanChartLabels,
  getSelectedActionTypeOrdinal,
  getSelectedChartTabIndex,
  getUi,
} from "../../config/selectors"

class BarChartByActionType extends React.Component {
  render() {
    return (
      <BarChart
        width={this.props.width}
        height={this.props.height}
        chartLabels={this.props.chartLabels}
        planActionIds={this.props.planActionIds}
        allActions={this.props.allActions}
        dispatch={this.props.dispatch}
        countActionsByActionType={this.props.countActionsByActionType}
        matrixOfActionCountsByActionTypeAndDisease={
          this.props.matrixOfActionCountsByActionTypeAndDisease
        }
        selectedActionTypeOrdinal={this.props.selectedActionTypeOrdinal}
        ui={this.props.ui}
      />
    )
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
  ui: PropTypes.object,
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
    ui: getUi(state),
  }
}

export default connect(mapStateToProps)(BarChartByActionType)
