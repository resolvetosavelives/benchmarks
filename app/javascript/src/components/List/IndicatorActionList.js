import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getActionsForIds,
  getAllActions,
  getIndicatorMap,
  getPlanActionIdsByIndicator,
  getPlanDiseases,
  getPlanGoalMap,
  getSortedActions,
  getTechnicalAreaMap,
} from "../../config/selectors"
import NoGoalForThisIndicator from "./NoGoalForThisIndicator"
import AddAction from "./AddAction"
import FilteredGeneralActions from "./FilteredGeneralActions"
import FilteredDiseaseActions from "./FilteredDiseaseActions"

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
  const planDiseases = useSelector((state) => getPlanDiseases(state))
  let actionsForIndicator = getActionsForIds(actionIdsByIndicator, actions)

  const noGoalForThisIndicator =
    goalForThisIndicator.value === null ? <NoGoalForThisIndicator /> : null

  const sortedActionsByIndicator = getSortedActions(
    actionsForIndicator,
    technicalAreaMap,
    indicatorMap
  )

  const actionGeneralComponents = (
    <FilteredGeneralActions actions={sortedActionsByIndicator} />
  )

  const actionDiseaseComponents = planDiseases.map((disease) => (
    <FilteredDiseaseActions
      actions={sortedActionsByIndicator}
      disease={disease}
      key={`action-component-${disease.name}`}
    />
  ))

  return (
    <>
      {noGoalForThisIndicator}
      {actionGeneralComponents}
      {actionDiseaseComponents}
      <AddAction indicator={indicator} />
    </>
  )
}

IndicatorActionList.propTypes = {
  indicator: PropTypes.object.isRequired,
}

export default IndicatorActionList
