import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getPlanGoalMap,
  getPlanActionIdsByIndicator,
  getAllActions,
  getActionsForIndicator,
  getSortedActionsForIndicator,
} from "../../config/selectors"
import Action from "./Action"
import NoGoalForThisIndicator from "./NoGoalForThisIndicator"
import AddAction from "./AddAction"

const IndicatorActionList = (props) => {
  const indicator = props.indicator
  const planGoalMap = useSelector((state) => getPlanGoalMap(state))
  const goalForThisIndicator = planGoalMap[indicator.id]
  const planActionIdsByIndicator = useSelector((state) =>
    getPlanActionIdsByIndicator(state)
  )
  const actionIdsByIndicator = planActionIdsByIndicator[indicator.id]
  const actions = useSelector((state) => getAllActions(state))
  const actionsForIndicator = getActionsForIndicator(
    actionIdsByIndicator,
    actions
  )
  const sortedActionsByIndicator = getSortedActionsForIndicator(
    actionsForIndicator
  )

  if (!goalForThisIndicator) {
    return <NoGoalForThisIndicator />
  }

  const actionComponents = sortedActionsByIndicator.map((action) => (
    <Action id={action.id} key={`action-${action.id}`} />
  ))
  return (
    <>
      {actionComponents}
      <AddAction indicator={indicator} />
    </>
  )
}

IndicatorActionList.propTypes = {
  indicator: PropTypes.object.isRequired,
}

export default IndicatorActionList
