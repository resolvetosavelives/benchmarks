import React, { useState } from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useDispatch, useSelector } from "react-redux"
import ActionBadge from "./ActionBadge"
import ActionBadgePill from "./ActionBadgePill"
import { CSSTransition } from 'react-transition-group';
import { Button } from 'react-bootstrap'

const Action = (props) => {
  const action = props.action
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const indicator = indicatorMap[action.benchmark_indicator_id]
  const [showDelete, setShowDelete] = useState(false)

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
            <p>You can always add this action back from the &ldquo;Add an activity&rdquo; form below.</p>
          </div>
          <div className="col-4 d-flex justify-content-end">
            <Button className="px-3 py-2" onClick={() => dispatch(deleteAnAction(action.id, indicator.id))}>
              Remove
            </Button>
            <Button className="px-3 py-2" variant="link" onClick={() => setShowDelete(false)}>
              Cancel
            </Button>
          </div>
        </div>
      </CSSTransition>
    )
  }

  return (
    <div className="row action">
      {deleteBanner()}
      <div className="col">
        <div className="row p-4">
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
              onClick={() => setShowDelete(true)}
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
