import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import { makeGetDiseaseForDiseaseId } from "../../config/selectors"

const ActionBadgePill = (props) => {
  const action = props.action
  const getDisease = makeGetDiseaseForDiseaseId(action.disease_id)
  const disease = useSelector((state) => getDisease(state))
  if (action.disease_id) {
    return (
      <span className="badge-light-gray badge-pill action-badge-pill">
        {disease.display}
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
