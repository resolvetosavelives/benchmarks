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
  SET_SELECTED_CHART_TAB_INDEX,
  DESELECT_ACTION_TYPE,
  DESELECT_TECHNICAL_AREA,
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

const deselectTechnicalArea = () => {
  return (dispatch) => {
    dispatch({
      type: DESELECT_TECHNICAL_AREA,
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

const deselectActionType = () => {
  return (dispatch) => {
    dispatch({
      type: DESELECT_ACTION_TYPE,
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

const toggleDiseaseShowing = (disease) => {
  const action = `IS_${disease.name.toUpperCase()}_SHOWING`
  return (dispatchedAction) => {
    dispatchedAction({ type: action })
  }
}

const setSelectedChartTabIndex = (tabIndex) => {
  return (dispatchedAction) => {
    dispatchedAction({
      type: SET_SELECTED_CHART_TAB_INDEX,
      payload: { tabIndex: tabIndex },
    })
  }
}

export {
  addActionToIndicator,
  deleteAnAction,
  deselectActionType,
  deselectTechnicalArea,
  selectTechnicalArea,
  selectActionType,
  clearFilterCriteria,
  updatePlanName,
  toggleDiseaseShowing,
  setSelectedChartTabIndex,
}
