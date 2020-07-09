import React from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useDispatch, useSelector } from "react-redux"
import ActionBadge from "./ActionBadge"
import ActionBadgeDisease from "./ActionBadgeDisease"
import ActionBadgePill from "./ActionBadgePill"

const Action = (props) => {
  const id = props.id
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const actionMap = useSelector((state) => state.actions)
  const action = actionMap[id]
  const indicator = indicatorMap[action.benchmark_indicator_id]

  return (
    <div className="action row p-2">
      <div className="col-12 col-md-auto d-flex flex-row align-items-center mb-2 mb-md-0">
        {action.level ? (
          <ActionBadge action={action} />
        ) : (
          <ActionBadgeDisease action={action} />
        )}
      </div>
      <div className="col-9">
        <strong>{indicator.display_abbreviation}</strong>
        &nbsp;
        <span className="action-text">{action.text}</span>
      </div>
      <div className="col-12 col-md-auto d-flex flex-row align-items-center py-2 py-md-0 ">
        <ActionBadgePill action={action} />
      </div>
      <div className="col d-flex d-md-block py-2 py-md-0">
        <button
          className="delete close"
          type="button"
          onClick={() => dispatch(deleteAnAction(action.id, indicator.id))}
        >
          <img src="/delete-button.svg" alt="Delete this action" />
        </button>
      </div>
    </div>
  )
}

Action.propTypes = {
  id: PropTypes.number.isRequired,
}

export default Action
