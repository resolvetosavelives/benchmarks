import React from "react"
import { useSelector } from "react-redux"
import NudgeByTechnicalAreaOneYear from "./NudgeByTechnicalAreaOneYear"
import NudgeByTechnicalAreaFiveYear from "./NudgeByTechnicalAreaFiveYear"

const NudgeByTechnicalArea = () => {
  let whichNudgeComponent
  const plan = useSelector((state) => state.plan)
  if (plan.term === 500) {
    whichNudgeComponent = <NudgeByTechnicalAreaFiveYear />
  } else {
    whichNudgeComponent = <NudgeByTechnicalAreaOneYear />
  }
  return (
    <div className="row m-0">
      <div className="col-12 col-md-4 col-lg-3 d-flex flex-column justify-content-center nudge-left px-4 py-4">
        <div className="nudge-tip-text">Tips for</div>
        <h4 className="my-0">Your draft plan</h4>
      </div>
      <div className="col-12 col-md-8 col-lg-9">{whichNudgeComponent}</div>
    </div>
  )
}

export default NudgeByTechnicalArea
