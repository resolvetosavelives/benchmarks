import React from "react"
import PropTypes from "prop-types"
import { getColorForDiseaseId } from "../../config/selectors"

const ActionBadgeDisease = (props) => {
  const action = props.action
  const colorForDisease = getColorForDiseaseId(action.disease_id)
  return (
    <span className="d-flex badge badge-rounded-circle justify-content-md-center px-0">
      <span
        className={`d-block rounded-circle badge-disease ${colorForDisease}`}
      />
    </span>
  )
}

ActionBadgeDisease.propTypes = {
  action: PropTypes.object.isRequired,
}

export default ActionBadgeDisease
