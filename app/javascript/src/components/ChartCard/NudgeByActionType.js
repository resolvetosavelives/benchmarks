import React from "react"
import { useSelector } from "react-redux"
import {
  getNudgesByActionType,
  getSelectedActionTypeOrdinal,
  countActionsByActionType,
} from "../../config/selectors"

const NudgeByActionType = () => {
  const nudgesByActionType = useSelector((state) =>
    getNudgesByActionType(state)
  )
  const selectedActionTypeOrdinal = useSelector((state) =>
    getSelectedActionTypeOrdinal(state)
  )
  const selectedActionTypeIndex = selectedActionTypeOrdinal - 1
  const countOfActions = useSelector((state) => countActionsByActionType(state))
  if (isNaN(selectedActionTypeOrdinal) || selectedActionTypeIndex < 0) {
    return getNudgeContentZero()
  }

  const nudgeData = nudgesByActionType[selectedActionTypeIndex]
  const listItems = getListItemsForNudge(
    countOfActions,
    selectedActionTypeIndex,
    nudgeData
  ).map((listItem, i) => (
    <li key={`${selectedActionTypeIndex}-${i}`}>{listItem}</li>
  ))
  return (
    <div className="col nudge-container">
      <div className="card" id="nudge-by-action-type">
        <p>
          <svg className="lightbulb" xmlns="http://www.w3.org/2000/svg">
            <path d="M8.57877 15.4626V16.4098C8.57877 16.7633 8.35903 17.0639 8.05245 17.1754V17.4924C8.05245 17.9409 7.699 18.3044 7.26298 18.3044H4.6314C4.19538 18.3044 3.84193 17.9409 3.84193 17.4924V17.1754C3.53535 17.0639 3.31561 16.7633 3.31561 16.4098V15.4626C3.31561 15.2384 3.49235 15.0566 3.71035 15.0566H8.18403C8.40202 15.0566 8.57877 15.2384 8.57877 15.4626ZM3.8713 13.974C3.54541 13.974 3.25202 13.7683 3.13525 13.4554C1.85827 10.034 0.157715 10.3787 0.157715 6.93701C0.157715 3.64869 2.74998 0.982666 5.94719 0.982666C9.14439 0.982666 11.7367 3.64869 11.7367 6.93701C11.7367 10.3787 10.0361 10.034 8.75916 13.4554C8.64239 13.7683 8.34896 13.974 8.02311 13.974H3.8713ZM3.31561 6.93701C3.31561 5.44464 4.49614 4.23049 5.94719 4.23049C6.23788 4.23049 6.4735 3.98812 6.4735 3.68919C6.4735 3.39025 6.23788 3.14788 5.94719 3.14788C3.91571 3.14788 2.26298 4.84768 2.26298 6.93701C2.26298 7.23595 2.49864 7.47832 2.78929 7.47832C3.07995 7.47832 3.31561 7.23595 3.31561 6.93701Z"></path>
          </svg>
          Tips for {nudgeData["action_type_name"]} actions
        </p>
        <ul>{listItems}</ul>
      </div>
    </div>
  )
}

const getNudgeContentZero = function () {
  return (
    <div className="col nudge-container">
      <div className="card" id="nudge-by-action-type">
        <div className="nudge-content-0">
          <div>
            <div className="ico-bar-chart">
              <svg className="bar-chart" xmlns="http://www.w3.org/2000/svg">
                <path d="M20.8333 13.3333C21.1083 13.3333 21.3333 13.5583 21.3333 13.8333V15.5C21.3333 15.775 21.1083 16 20.8333 16H0.5C0.225 16 0 15.775 0 15.5V0.5C0 0.225 0.225 0 0.5 0H2.16667C2.44167 0 2.66667 0.225 2.66667 0.5V13.3333H20.8333ZM8 11.5V8.5C8 8.225 7.775 8 7.5 8H5.83333C5.55833 8 5.33333 8.225 5.33333 8.5V11.5C5.33333 11.775 5.55833 12 5.83333 12H7.5C7.775 12 8 11.775 8 11.5ZM16 11.5V5.83333C16 5.55833 15.775 5.33333 15.5 5.33333H13.8333C13.5583 5.33333 13.3333 5.55833 13.3333 5.83333V11.5C13.3333 11.775 13.5583 12 13.8333 12H15.5C15.775 12 16 11.775 16 11.5ZM12 11.5V3.16667C12 2.89167 11.775 2.66667 11.5 2.66667H9.83333C9.55833 2.66667 9.33333 2.89167 9.33333 3.16667V11.5C9.33333 11.775 9.55833 12 9.83333 12H11.5C11.775 12 12 11.775 12 11.5ZM20 11.5V1.83333C20 1.55833 19.775 1.33333 19.5 1.33333H17.8333C17.5583 1.33333 17.3333 1.55833 17.3333 1.83333V11.5C17.3333 11.775 17.5583 12 17.8333 12H19.5C19.775 12 20 11.775 20 11.5Z"></path>
              </svg>
            </div>
            <svg className="cursor" xmlns="http://www.w3.org/2000/svg">
              <path d="M9.4434 10.2852H6.12828L7.873 14.535C7.99453 14.8296 7.85565 15.1599 7.57787 15.2849L6.04146 15.9545C5.75506 16.0795 5.43387 15.9367 5.31234 15.651L3.65444 11.6155L0.946187 14.401C0.585281 14.7722 0 14.486 0 13.9993V0.571835C0 0.0593356 0.622531 -0.190508 0.946156 0.170086L9.83403 9.31202C10.1925 9.66136 9.92799 10.2852 9.4434 10.2852Z"></path>
            </svg>
          </div>
          <h4>
            Click on any bar in the chart to get tips on how to consolidate and
            prioritize your plan.
          </h4>
        </div>
      </div>
    </div>
  )
}

const getListItemsForNudge = function (
  countOfActions,
  selectedActionTypeIndex,
  nudgeData
) {
  const thresholdA = nudgeData["threshold_a"]
  const thresholdB = nudgeData["threshold_b"]
  let indexForThreshold = getIndexForThreshold(
    countOfActions[selectedActionTypeIndex],
    thresholdA,
    thresholdB
  )
  const contentKey = ["content_for_a", "content_for_b", "content_for_c"][
    indexForThreshold
  ]
  return nudgeData[contentKey].split("\n")
}

const getIndexForThreshold = function (
  currentActionCount,
  thresholdA,
  thresholdB
) {
  if (thresholdA && thresholdB) {
    return getIndexForThresholdOfTwo(currentActionCount, thresholdA, thresholdB)
  } else {
    return getIndexForThresholdOfOne(currentActionCount, thresholdA)
  }
}

const getIndexForThresholdOfTwo = function (
  currentActionCount,
  thresholdA,
  thresholdB
) {
  if (currentActionCount < thresholdA) {
    return 0
  } else if (
    thresholdA <= currentActionCount &&
    currentActionCount <= thresholdB
  ) {
    return 1
  } else if (thresholdB < currentActionCount) {
    return 2
  }
}

const getIndexForThresholdOfOne = function (currentActionCount, threshold) {
  if (currentActionCount < threshold) {
    return 0
  } else if (threshold <= currentActionCount) {
    return 1
  }
}

export default NudgeByActionType
