import React from "react"
import { useSelector } from "react-redux"
import { CHART_TAB_INDEX_FOR_ACTION_TYPE } from "../../config/constants"
import { getSelectedChartTabIndex } from "../../config/selectors"
import NudgeByTechnicalArea from "./NudgeByTechnicalArea"
import NudgeByActionType from "./NudgeByActionType"

const Nudges = () => {
  const selectedChartTabIndex = useSelector((state) =>
    getSelectedChartTabIndex(state)
  )
  return (
    <div className="row">
      <div className="col-12 mt-4">
        <div className="card nudge-container d-flex flex-row">
          {whichNudgeToShow(selectedChartTabIndex)}
        </div>
      </div>
    </div>
  )
}

const whichNudgeToShow = (selectedChartTabIndex) => {
  if (selectedChartTabIndex === CHART_TAB_INDEX_FOR_ACTION_TYPE) {
    return <NudgeByActionType />
  } else {
    return <NudgeByTechnicalArea />
  }
}

export default Nudges
