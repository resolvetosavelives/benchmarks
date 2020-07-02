import React from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useSelector, useDispatch } from "react-redux"

const Action = (props) => {
  const id = props.id
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const actionMap = useSelector((state) => state.actions)
  const action = actionMap[id]
  const indicator = indicatorMap[action.benchmark_indicator_id]

  return (
    <div className="action row p-2">
      <div className="col-auto d-flex flex-row align-items-center">
        <span
          className={`badge badge-pill badge-success badge-rounded-circle color-value-${action.level}`}
        >
          <span className="action-level">{action.level}</span>
        </span>
      </div>
      <div className="col-10">
        <strong>{indicator.display_abbreviation}</strong>
        &nbsp;
        <span className="action-text">{action.text}</span>
      </div>
      <div className="col">
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
