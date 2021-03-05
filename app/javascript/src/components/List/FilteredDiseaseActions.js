import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  makeGetDiseaseIsShowingForDisease,
  filterActionsForDiseaseId,
} from "../../config/selectors"
import Action from "./Action"
import FilteredGeneralActions from "./FilteredGeneralActions"

const FilteredDiseaseActions = (props) => {
  const actions = props.actions
  const disease = props.disease
  const getIsDiseaseShowing = makeGetDiseaseIsShowingForDisease(disease)
  const isDiseaseShowing = useSelector((state) => getIsDiseaseShowing(state))

  if (!isDiseaseShowing) {
    return null
  }

  const filteredActions = filterActionsForDiseaseId(actions, disease.id)

  return filteredActions.map((action) => (
    <Action action={action} key={`action-${action.id}`} />
  ))
}

FilteredGeneralActions.propTypes = {
  actions: PropTypes.array.isRequired,
  disease: PropTypes.object.isRequired,
}

export default FilteredDiseaseActions
