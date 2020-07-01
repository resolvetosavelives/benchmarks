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
  LIST_MODE_BY_TECHNICAL_AREA,
  SWITCH_LIST_MODE,
  UPDATE_PLAN_NAME,
} from "./constants"

export default function initReducers(initialState) {
  const technicalAreas = createReducer(initialState.technicalAreas, {})

  const indicators = createReducer(initialState.indicators, {})
  const indicatorMapInitial = initialState.indicators.reduce(
    (map, indicator) => {
      map[indicator.id] = indicator
      return map
    },
    {}
  )
  const indicatorMap = createReducer(indicatorMapInitial, {})

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

  const selectedTechnicalAreaId = createReducer(null, {
    [SELECT_TECHNICAL_AREA]: (state, dispatchedAction) => {
      return dispatchedAction.payload.technicalAreaId
    },
    // eslint-disable-next-line no-unused-vars
    [DESELECT_TECHNICAL_AREA]: (state, dispatchedAction) => {
      return null
    },
  })

  const selectedActionTypeOrdinal = createReducer(null, {
    [SELECT_ACTION_TYPE]: (state, dispatchedAction) => {
      return dispatchedAction.payload.actionTypeOrdinal
    },
    // eslint-disable-next-line no-unused-vars
    [DESELECT_ACTION_TYPE]: (state, dispatchedAction) => {
      return null
    },
  })

  const allActions = createReducer(initialState.actions, {})

  const selectedListMode = createReducer(LIST_MODE_BY_TECHNICAL_AREA, {
    [SWITCH_LIST_MODE]: (state, dispatchedAction) => {
      return dispatchedAction.payload.listModeOrdinal
    },
  })

  const initialPlanGoalMap = initialState.planGoals.reduce((acc, goal) => {
    acc[goal.benchmark_indicator_id] = goal
    return acc
  }, {})
  const planGoalMap = createReducer(initialPlanGoalMap, {})

  const nudgesByActionType = createReducer(initialState.nudgesByActionType, {})

  const plan = createReducer(initialState.plan, {
    [UPDATE_PLAN_NAME]: (state, dispatchedAction) => {
      state.name = dispatchedAction.payload.name
    },
  })

  return combineReducers({
    technicalAreas,
    indicators,
    indicatorMap,
    actions,
    planActionIds,
    planActionIdsByIndicator,
    planActionIdsNotInIndicator,
    planChartLabels,
    allActions,
    selectedTechnicalAreaId,
    selectedActionTypeOrdinal,
    selectedListMode,
    planGoalMap,
    nudgesByActionType,
    plan,
  })
}
