import React from "react"

const NoGoalForThisIndicator = () => {
  return (
    <div className="row p-3 no-actions">
      <div className="col font-italic">
        There is no capacity gap for actions. You should review the Benchmarks
        document to ensure you have completed the tasks up to this level.
      </div>
    </div>
  )
}

export default NoGoalForThisIndicator
