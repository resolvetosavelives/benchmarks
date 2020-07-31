import React from "react"
import { useDispatch, useSelector } from "react-redux"
import { getIsInfluenzaShowing, isPlanInfluenza } from "../config/selectors"
import { toggleInfluenzaShowing } from "../config/actions"

const InfluenzaToggle = () => {
  const dispatch = useDispatch()
  const eventHandler = (e) => {
    e.preventDefault()
    dispatch(toggleInfluenzaShowing())
  }
  const isInfluenza = useSelector((state) => isPlanInfluenza(state))
  const isInfluenzaShowing = useSelector((state) =>
    getIsInfluenzaShowing(state)
  )
  if (!isInfluenza) {
    return null
  }

  return (
    <div className="row">
      <div className="col mt-4 mb-5">
        <div className="card d-flex flex-row align-items-center p-3">
          <p className="d-flex m-0">Filter disease-specific actions</p>
          <button
            className="influenza-toggle btn btn-primary d-flex flex-row align-items-center justify-content-start ml-3 px-3 "
            onClick={eventHandler}
          >
            {displayCheckmark(isInfluenzaShowing)}
            Influenza
          </button>
        </div>
      </div>
    </div>
  )
}

const displayCheckmark = (isInfluenzaShowing) => {
  if (isInfluenzaShowing) {
    return (
      <span className="checkmark-box with-checkmark d-flex flex-row align-items-center mr-2">
        &nbsp;
      </span>
    )
  } else {
    return (
      <span className="checkmark-box with-circle    d-flex flex-row align-items-center mr-2">
        &nbsp;
      </span>
    )
  }
}

export default InfluenzaToggle
