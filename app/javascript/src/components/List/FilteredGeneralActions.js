import React from "react"
import PropTypes from "prop-types"
import { filterActionsForDiseaseId } from "../../config/selectors"
import Action from "./Action"

const FilteredGeneralActions = (props) => {
  const actions = props.actions
  const filteredActions = filterActionsForDiseaseId(actions, null)

  return filteredActions.map((action) => (
    <Action action={action} key={`action-${action.id}`} />
  ))
}

FilteredGeneralActions.propTypes = {
  actions: PropTypes.array.isRequired,
}

export default FilteredGeneralActions
