import React from "react"
import PropTypes from "prop-types"

const ActionBadge = (props) => {
  const action = props.action
  return (
    <span
      className={`badge badge-pill badge-success badge-rounded-circle color-value-${action.level}`}
    >
      <span className="action-level">{action.level}</span>
    </span>
  )
}

ActionBadge.propTypes = {
  action: PropTypes.object.isRequired,
}

export default ActionBadge
