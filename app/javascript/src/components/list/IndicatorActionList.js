import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import Action from "./Action"
import NoGoalForThisIndicator from "./NoGoalForThisIndicator"
import AddAction from "./AddAction"

const IndicatorActionList = (props) => {
  const indicator = props.indicator
  const planGoalMap = useSelector((state) => state.planGoalMap)
  const goalForThisIndicator = planGoalMap[indicator.id]
  const planActionIdsByIndicator = useSelector((state) => {
    return state.planActionIdsByIndicator
  })
  if (!goalForThisIndicator) {
    return <NoGoalForThisIndicator />
  }

  const actionIdsByIndicator = planActionIdsByIndicator[indicator.id]
  const actionComponents = actionIdsByIndicator.map((actionId) => (
    <Action id={actionId} key={"action-" + indicator.id + "-" + actionId} />
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
