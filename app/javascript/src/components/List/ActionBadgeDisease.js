import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import { getAllDiseases } from "../../config/selectors"
import { getColorForDiseaseId } from "../../config/helpers"

const ActionBadgeDisease = (props) => {
  const action = props.action
  const diseases = useSelector((state) => getAllDiseases(state))
  const colorForDisease = getColorForDiseaseId(diseases, action.disease_id)
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
