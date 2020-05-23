import React from "react"
import { useSelector, useDispatch } from "react-redux"
import { clearFilterCriteria } from "../config/actions"

const ActionCount = () => {
  const countOfPlanActionIds = useSelector((state) => {
    return state.planActionIds.length
  })
  const dispatch = useDispatch()

  return (
    <div className="row action-count-header align-items-center mx-0">
      <div
        onClick={() => dispatch(clearFilterCriteria())}
        className="action-count-circle col-auto d-flex flex-column align-items-center justify-content-center"
      >
        <span>{countOfPlanActionIds}</span>
      </div>
      <div className="col-auto">
        <p>Total Actions</p>
      </div>
    </div>
  )
}

export default ActionCount
