import React from "react"
import { useSelector } from "react-redux"
import { LIST_MODE_BY_ACTION_TYPE } from "../../config/constants"
import ActionListByActionType from "./ActionListByActionType"
import ActionListByTechnicalArea from "./ActionListByTechnicalArea"

const ActionList = () => {
  const listMode = useSelector((state) => {
    return state.selectedListMode
  })
  let whichListToRender
  if (listMode === LIST_MODE_BY_ACTION_TYPE) {
    whichListToRender = <ActionListByActionType />
  } else {
    whichListToRender = <ActionListByTechnicalArea />
  }
  return whichListToRender
}

export default ActionList
