import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import { makeGetDisplayForDiseaseId } from "../../config/selectors"

const ActionBadgePill = (props) => {
  const action = props.action
  const getDisplayForDiseaseId = makeGetDisplayForDiseaseId(action.disease_id)
  const diseaseDisplayName = useSelector((state) =>
    getDisplayForDiseaseId(state)
  )
  if (action.disease_id) {
    return (
      <span className="badge-light-gray badge-pill action-badge-pill">
        {diseaseDisplayName}
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
