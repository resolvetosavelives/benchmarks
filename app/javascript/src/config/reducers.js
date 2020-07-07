import { combineReducers, createReducer } from "@reduxjs/toolkit"
import {
  ADD_ACTION_TO_PLAN,
  ADD_ACTION_TO_INDICATOR,
  ADD_ACTION_TO_NOT_IN_INDICATOR,
  DELETE_ACTION_FROM_PLAN,
  DELETE_ACTION_FROM_INDICATOR,
  DELETE_ACTION_FROM_NOT_IN_INDICATOR,
  SELECT_TECHNICAL_AREA,
  DESELECT_TECHNICAL_AREA,
  SELECT_ACTION_TYPE,
  DESELECT_ACTION_TYPE,
  SWITCH_LIST_MODE,
  UPDATE_PLAN_NAME,
  CLEAR_FILTERS,
} from "./constants"

export default function initReducers(initialState) {
  const technicalAreas = createReducer(initialState.technicalAreas, {})

  const indicators = createReducer(initialState.indicators, {})

  const actionMap = initialState.actions.reduce((map, action) => {
    map[action.id] = action
    return map
  }, {})
  const actions = createReducer(actionMap, {})

  const planActionIds = createReducer(initialState.planActionIds, {
    [ADD_ACTION_TO_PLAN]: (state, action) => {
      const actionIdToAdd = action.payload.actionId
      state.push(actionIdToAdd)
    },
    [DELETE_ACTION_FROM_PLAN]: (state, action) => {
      const actionIdToDelete = action.payload.actionId
      return state.filter((actionId) => actionId !== actionIdToDelete)
    },
  })

  const initialMapOfPlanActionIdsByIndicator = {}
  const initialMapOfPlanActionIdsNotInIndicator = {}
  let currentIndicatorId
  initialState.actions.forEach((action) => {
    if (action.benchmark_indicator_id !== currentIndicatorId) {
      currentIndicatorId = action.benchmark_indicator_id
    }
    if (!initialMapOfPlanActionIdsByIndicator[currentIndicatorId]) {
      initialMapOfPlanActionIdsByIndicator[currentIndicatorId] = []
    }
    if (!initialMapOfPlanActionIdsNotInIndicator[currentIndicatorId]) {
      initialMapOfPlanActionIdsNotInIndicator[currentIndicatorId] = []
    }
    if (initialState.planActionIds.indexOf(action.id) >= 0) {
      initialMapOfPlanActionIdsByIndicator[currentIndicatorId].push(action.id)
    } else {
      initialMapOfPlanActionIdsNotInIndicator[currentIndicatorId].push(
        action.id
      )
    }
  })
  const planActionIdsByIndicator = createReducer(
    initialMapOfPlanActionIdsByIndicator,
    {
      [ADD_ACTION_TO_INDICATOR]: (state, action) => {
        const indicatorId = action.payload.indicatorId
        const actionId = action.payload.actionId
        state[indicatorId].push(actionId)
      },
      [DELETE_ACTION_FROM_INDICATOR]: (state, action) => {
        const indicatorId = action.payload.indicatorId
        const actionId = action.payload.actionId
        state[indicatorId] = state[indicatorId].filter(
          (aid) => aid !== actionId
        )
      },
    }
  )
  const planActionIdsNotInIndicator = createReducer(
    initialMapOfPlanActionIdsNotInIndicator,
    {
      [ADD_ACTION_TO_NOT_IN_INDICATOR]: (state, action) => {
        const indicatorId = action.payload.indicatorId
        const actionId = action.payload.actionId
        state[indicatorId].unshift(actionId)
      },
      [DELETE_ACTION_FROM_NOT_IN_INDICATOR]: (state, action) => {
        const indicatorId = action.payload.indicatorId
        const actionId = action.payload.actionId
        state[indicatorId] = state[indicatorId].filter(
          (aid) => aid !== actionId
        )
      },
    }
  )

  const planChartLabels = createReducer(initialState.planChartLabels, {})

  const allActions = createReducer(initialState.actions, {})

  const planGoals = createReducer(initialState.planGoals, {})

  const nudgesByActionType = createReducer(initialState.nudgesByActionType, {})

  const plan = createReducer(initialState.plan, {
    [UPDATE_PLAN_NAME]: (state, dispatchedAction) => {
      state.name = dispatchedAction.payload.name
    },
  })

  const ui = createReducer(
    {
      selectedListMode: null,
      selectedTechnicalAreaId: null,
      selectedActionTypeOrdinal: null,
    },
    {
      [SWITCH_LIST_MODE]: (state, dispatchedAction) => {
        state.selectedListMode = dispatchedAction.payload.listModeOrdinal
        return state
      },
      [SELECT_TECHNICAL_AREA]: (state, dispatchedAction) => {
        state.selectedTechnicalAreaId = dispatchedAction.payload.technicalAreaId
        return state
      },
      [DESELECT_TECHNICAL_AREA]: (state /*, dispatchedAction*/) => {
        state.selectedTechnicalAreaId = null
        return state
      },
      [SELECT_ACTION_TYPE]: (state, dispatchedAction) => {
        // NB: the reason we use "actionTypeIndex + 1" is because actionTypeIndex is
        //   zero-based but the actual ordinals used as ActionType IDs are 1-based, e.g. 0-14 => 1-15.
        state.selectedActionTypeOrdinal =
          dispatchedAction.payload.actionTypeIndex + 1
        return state
      },
      [DESELECT_ACTION_TYPE]: (state /*, dispatchedAction*/) => {
        state.selectedActionTypeOrdinal = null
        return state
      },
      [CLEAR_FILTERS]: (/*state, dispatchedAction*/) => {
        return {
          selectedListMode: null,
          selectedTechnicalAreaId: null,
          selectedActionTypeOrdinal: null,
        }
      },
    }
  )

  return combineReducers({
    technicalAreas,
    indicators,
    actions,
    planActionIds,
    planGoals,
    planActionIdsByIndicator,
    planActionIdsNotInIndicator,
    planChartLabels,
    allActions,
    ui,
    nudgesByActionType,
    plan,
  })
}
