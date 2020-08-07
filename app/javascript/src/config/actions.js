import {
  ADD_ACTION_TO_PLAN,
  ADD_ACTION_TO_INDICATOR,
  ADD_ACTION_TO_NOT_IN_INDICATOR,
  DELETE_ACTION_FROM_PLAN,
  DELETE_ACTION_FROM_INDICATOR,
  DELETE_ACTION_FROM_NOT_IN_INDICATOR,
  SELECT_TECHNICAL_AREA,
  SELECT_ACTION_TYPE,
  SWITCH_LIST_MODE,
  LIST_MODE_BY_TECHNICAL_AREA,
  LIST_MODE_BY_ACTION_TYPE,
  UPDATE_PLAN_NAME,
  CLEAR_FILTERS,
  IS_INFLUENZA_SHOWING,
} from "./constants"

const deleteAnAction = (actionId, indicatorId) => {
  return (dispatch) => {
    dispatch({
      type: DELETE_ACTION_FROM_PLAN,
      payload: { actionId: actionId },
    })
    dispatch({
      type: DELETE_ACTION_FROM_INDICATOR,
      payload: { actionId: actionId, indicatorId: indicatorId },
    })
    dispatch({
      type: ADD_ACTION_TO_NOT_IN_INDICATOR,
      payload: { actionId: actionId, indicatorId: indicatorId },
    })
  }
}

const addActionToIndicator = (actionId, indicatorId) => {
  return (dispatch) => {
    dispatch({
      type: ADD_ACTION_TO_PLAN,
      payload: { actionId: actionId },
    })
    dispatch({
      type: ADD_ACTION_TO_INDICATOR,
      payload: { actionId: actionId, indicatorId: indicatorId },
    })
    dispatch({
      type: DELETE_ACTION_FROM_NOT_IN_INDICATOR,
      payload: { actionId: actionId, indicatorId: indicatorId },
    })
  }
}

const selectTechnicalArea = (technicalAreaId) => {
  return (dispatch) => {
    dispatch({
      type: SELECT_TECHNICAL_AREA,
      payload: { technicalAreaId: technicalAreaId },
    })
    dispatch({
      type: SWITCH_LIST_MODE,
      payload: { listModeOrdinal: LIST_MODE_BY_TECHNICAL_AREA },
    })
  }
}

const selectActionType = (actionTypeIndex) => {
  return (dispatch) => {
    dispatch({
      type: SELECT_ACTION_TYPE,
      payload: { actionTypeIndex: actionTypeIndex },
    })
    dispatch({
      type: SWITCH_LIST_MODE,
      payload: { listModeOrdinal: LIST_MODE_BY_ACTION_TYPE },
    })
  }
}

const clearFilterCriteria = () => {
  return (dispatch) => {
    dispatch({
      type: CLEAR_FILTERS,
    })
  }
}

const updatePlanName = (name) => {
  return (dispatch) => {
    dispatch({ type: UPDATE_PLAN_NAME, payload: { name: name } })
  }
}

const toggleInfluenzaShowing = () => {
  return (dispatchedAction) => {
    dispatchedAction({ type: IS_INFLUENZA_SHOWING })
  }
}

export {
  addActionToIndicator,
  deleteAnAction,
  selectTechnicalArea,
  selectActionType,
  clearFilterCriteria,
  updatePlanName,
  toggleInfluenzaShowing,
}
