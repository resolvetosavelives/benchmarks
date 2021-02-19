import React from "react"
import { useSelector } from "react-redux"
import {
  getActionsForIds,
  getAllActions,
  getIndicatorMap,
  getActionMap,
  getPlanActionIds,
  getSelectedActionTypeOrdinal,
  getSortedActions,
  getTechnicalAreaMap,
} from "../../config/selectors"
import Action from "./Action"

const ActionListByActionType = () => {
  const planActionIds = useSelector((state) => getPlanActionIds(state))
  const actionMap = useSelector((state) => getActionMap(state))
  const selectedActionTypeOrdinal = useSelector((state) =>
    getSelectedActionTypeOrdinal(state)
  )
  const actionIdsToDisplay = planActionIds.filter((actionId) => {
    const currentAction = actionMap[actionId]
    const action_types = currentAction.action_types || []
    return action_types.indexOf(selectedActionTypeOrdinal) >= 0
  })
  const actions = useSelector((state) => getAllActions(state))
  const actionsToDisplay = getActionsForIds(actionIdsToDisplay, actions)
  const technicalAreaMap = useSelector((state) => getTechnicalAreaMap(state))
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const sortedActions = getSortedActions(
    actionsToDisplay,
    technicalAreaMap,
    indicatorMap
  )

  const actionComponents = sortedActions.map((action) => {
    return <Action action={action} key={`action-${action.id}`} />
  })

  const chartLabels = useSelector((state) => state.planChartLabels)
  const chartLabelsByActionType = chartLabels[1]
  const nameOfSelectedActionType =
    chartLabelsByActionType[selectedActionTypeOrdinal - 1]

  return (
    <div id="action-list-by-type-container" className="col-auto w-100">
      <h3>{nameOfSelectedActionType} Actions</h3>
      <div className="col">{actionComponents}</div>
    </div>
  )
}

export default ActionListByActionType
