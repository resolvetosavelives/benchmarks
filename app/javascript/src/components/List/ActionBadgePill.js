import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import { getPlan, makeGetDisplayForDiseaseId } from "../../config/selectors"

const ActionBadgePill = (props) => {
  const action = props.action
  const plan = useSelector((state) => getPlan(state))
  const getDisplayForDiseaseId = makeGetDisplayForDiseaseId(plan.disease_ids)
  const display = useSelector((state) => getDisplayForDiseaseId(state))
  if (action.disease_id) {
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
