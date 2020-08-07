import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getActionsForIds,
  getAllActions,
  getIndicatorMap,
  getPlanActionIdsByIndicator,
  getPlanGoalMap,
  getSortedActions,
  getTechnicalAreaMap,
  filterOutInfluenzaActions,
  getIsInfluenzaShowing,
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
  const technicalAreaMap = useSelector((state) => getTechnicalAreaMap(state))
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  let actionsForIndicator = getActionsForIds(actionIdsByIndicator, actions)
  const isInfluenzaShowing = useSelector((state) =>
    getIsInfluenzaShowing(state)
  )
  if (!isInfluenzaShowing) {
    actionsForIndicator = filterOutInfluenzaActions(actionsForIndicator)
  }
  const sortedActionsByIndicator = getSortedActions(
    actionsForIndicator,
    technicalAreaMap,
    indicatorMap
  )
  if (!goalForThisIndicator) {
    return <NoGoalForThisIndicator />
  }

  const actionComponents = sortedActionsByIndicator.map((action) => (
    <Action action={action} key={`action-${action.id}`} />
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
