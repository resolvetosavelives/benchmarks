import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getActionsForIndicator,
  getPlanDiseases,
  getPlanGoalMap,
} from "../../config/selectors"
import NoGoalForThisIndicator from "./NoGoalForThisIndicator"
import AddAction from "./AddAction"
import FilteredGeneralActions from "./FilteredGeneralActions"
import FilteredDiseaseActions from "./FilteredDiseaseActions"

const IndicatorActionList = (props) => {
  const indicator = props.indicator
  const planGoalMap = useSelector((state) => getPlanGoalMap(state))
  const goalForThisIndicator = planGoalMap[indicator.id]
  const planDiseases = useSelector((state) => getPlanDiseases(state))
  const sortedActionsByIndicator = useSelector((state) =>
    getActionsForIndicator(state, indicator)
  )

  const noGoalForThisIndicator =
    goalForThisIndicator.value === null ? <NoGoalForThisIndicator /> : null

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
