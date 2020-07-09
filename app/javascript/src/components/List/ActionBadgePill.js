import React from "react"
import PropTypes from "prop-types"
import { getDisplayForDiseaseId } from "../../config/selectors"

const ActionBadgePill = (props) => {
  const action = props.action
  if (action.disease_id) {
    const display = getDisplayForDiseaseId(action.disease_id)
    return (
      <span className="badge-light-gray badge-pill action-badge-pill">
        {display}
      </span>
    )
  } else {
    return null
  }
}

ActionBadgePill.propTypes = {
  action: PropTypes.object.isRequired,
}

export default ActionBadgePill
