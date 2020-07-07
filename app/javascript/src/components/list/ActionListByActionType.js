import React from "react"
import { useSelector } from "react-redux"
import {
  getPlanActionIds,
  getSelectedActionTypeOrdinal,
} from "../../config/selectors"
import Action from "./Action"

const ActionListByActionType = () => {
  const planActionIds = useSelector((state) => getPlanActionIds(state))
  const actionMap = useSelector((state) => state.actions)
  const selectedActionTypeOrdinal = useSelector((state) =>
    getSelectedActionTypeOrdinal(state)
  )
  const actionIdsToDisplay = planActionIds.filter((actionId) => {
    const currentAction = actionMap[actionId]
    const action_types = currentAction.action_types || []
    return action_types.indexOf(selectedActionTypeOrdinal) >= 0
  })
  const actionComponents = actionIdsToDisplay.map((actionId) => {
    return <Action id={actionId} key={actionId} />
  })
  const chartLabels = useSelector((state) => state.planChartLabels)
  const chartLabelsByActionType = chartLabels[1]
  const nameOfSelectedActionType =
    chartLabelsByActionType[selectedActionTypeOrdinal - 1]
  return (
    <div id="action-list-by-type-container" className="col-auto w-100">
      <h2>{nameOfSelectedActionType} Actions</h2>
      <div className="col">{actionComponents}</div>
    </div>
  )
}

export default ActionListByActionType
