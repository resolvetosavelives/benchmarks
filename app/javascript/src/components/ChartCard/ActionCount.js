import React from "react"
import { useSelector } from "react-redux"
import { getCountOfPlanActionIds } from "../../config/selectors"

const ActionCount = () => {
  const countOfPlanActionIds = useSelector((state) =>
    getCountOfPlanActionIds(state)
  )

  return (
    <div className="col row action-count-component d-flex flex-column mb-4">
      <div className="col-auto count">{countOfPlanActionIds}</div>
      <div className="col-auto label">Actions</div>
    </div>
  )
}

export default ActionCount
