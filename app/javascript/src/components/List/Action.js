import React, { useState } from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useDispatch, useSelector } from "react-redux"
import ActionBadge from "./ActionBadge"
import ActionBadgePill from "./ActionBadgePill"
import { CSSTransition } from "react-transition-group"
import { Button } from "react-bootstrap"

const Action = (props) => {
  const action = props.action
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const indicator = indicatorMap[action.benchmark_indicator_id]
  const [showDelete, setShowDelete] = useState(false)

  function removeAction() {
    dispatch(deleteAnAction(action.id, indicator.id))
  }

  function deleteBanner() {
    return (
      <CSSTransition
        in={showDelete}
        timeout={1000}
        classNames="confirm-delete"
        unmountOnExit
      >
        <div className="delete-banner p-2 d-flex align-items-center">
          <div className="col-8">
            <h4 className="my-2">Remove this action?</h4>
            <p>
              You can always add this action back from the &ldquo;Add an
              activity&rdquo; form below.
            </p>
          </div>
          <div className="col-md-4 d-flex justify-content-end">
            <Button
              variant="remove"
              className="mx-2 px-3 py-2"
              onClick={removeAction}
            >
              Remove
            </Button>
            <Button
              variant="cancel"
              className="mx-2 px-3 py-2"
              onClick={() => setShowDelete(false)}
            >
              Cancel
            </Button>
          </div>
        </div>
      </CSSTransition>
    )
  }

  return (
    <div className="row action py-4">
      {deleteBanner()}
      <div className="col">
        <strong>{indicator.display_abbreviation}</strong>
        &nbsp;
        <span className="action-text">{action.text}</span>
      </div>
      <div
        className="col-12 col-md-auto flex-grow-0 mt-2 mt-md-0
        d-flex flex-row justify-content-between
        align-items-md-center justify-content-md-end"
      >
        {action.disease_id ? (
          <ActionBadgePill action={action} />
        ) : (
          <ActionBadge action={action} />
        )}
        <button
          className="delete close ml-md-3"
          type="button"
          onClick={() => setShowDelete(true)}
        >
          <img src="/delete-button.svg" alt="Delete this action" />
          <span className="d-md-none ml-1">Remove</span>
        </button>
      </div>
    </div>
  )
}

Action.propTypes = {
  action: PropTypes.object.isRequired,
}

export default Action
