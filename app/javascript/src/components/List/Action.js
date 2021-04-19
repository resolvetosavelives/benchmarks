import React from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useDispatch, useSelector } from "react-redux"
import ActionBadge from "./ActionBadge"
import ActionBadgePill from "./ActionBadgePill"

const Action = (props) => {
  const action = props.action
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const indicator = indicatorMap[action.benchmark_indicator_id]

  return (
    <div className="row action">
      <div className="col">
        <div className="row p-2">
          <div className="col-10">
            <strong>{indicator.display_abbreviation}</strong>
            &nbsp;
            <span className="action-text">{action.text}</span>
          </div>
          <div className="col-1 d-flex flex-row align-items-center justify-content-end py-2 py-md-0 ">
            {action.disease_id ? (
              <ActionBadgePill action={action} />
            ) : (
              <ActionBadge action={action} />
            )}
          </div>
          <div className="col-1 d-flex d-md-block py-2 py-md-0">
            <button
              className="delete close"
              type="button"
              onClick={() => dispatch(deleteAnAction(action.id, indicator.id))}
            >
              <img src="/delete-button.svg" alt="Delete this action" />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

Action.propTypes = {
  action: PropTypes.object.isRequired,
}

export default Action
