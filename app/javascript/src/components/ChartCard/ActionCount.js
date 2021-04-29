import React from "react"
import { useSelector } from "react-redux"
import { getCountOfPlanActionIds } from "../../config/selectors"

const ActionCount = () => {
  const countOfPlanActionIds = useSelector((state) =>
    getCountOfPlanActionIds(state)
  )

  return (
    <div className="col-5 col-md-3 col-xl-12 d-flex flex-column action-count-component">
      <div className="count">{countOfPlanActionIds}</div>
      <div className="label">Actions</div>
    </div>
  )
}

export default ActionCount
