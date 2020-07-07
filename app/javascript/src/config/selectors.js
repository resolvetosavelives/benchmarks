import { createSelector } from "reselect"

const getAllTechnicalAreas = (state) => state.technicalAreas
const getAllIndicators = (state) => state.indicators
const getAllActions = (state) => state.allActions
const getActionTypes = (state) => state.nudgesByActionType
const getNumOfActionTypes = (state) => getActionTypes(state).length

const getPlanActionIds = (state) => state.planActionIds
const getPlanGoals = (state) => state.planGoals

const getPlanGoalMap = createSelector([getPlanGoals], (goals) => {
  return goals.reduce((acc, goal) => {
    acc[goal.benchmark_indicator_id] = goal
    return acc
  }, {})
})

const getActionsForIds = createSelector(
  [getPlanActionIds, getAllActions],
  (actionIds, actions) => {
    return actions.filter((action) => actionIds.indexOf(action.id) >= 0)
  }
)

const getTechnicalAreaMap = createSelector(
  [getAllTechnicalAreas],
  (technicalAreas) => {
    return technicalAreas.reduce((map, technicalArea) => {
      map[technicalArea.id] = technicalArea
      return map
    }, {})
  }
)

const getIndicatorMap = createSelector([getAllIndicators], (indicators) => {
  return indicators.reduce((map, indicator) => {
    map[indicator.id] = indicator
    return map
  }, {})
})

const countActionsByTechnicalArea = createSelector(
  [getActionsForIds, getTechnicalAreaMap],
  (currentActions, technicalAreaMap) => {
    return currentActions.reduce((acc, action) => {
      const technicalArea = technicalAreaMap[action.benchmark_technical_area_id]
      console.assert(
        technicalArea,
        `technicalArea expected but found ${technicalArea}`
      )
      const currentIndex = technicalArea.sequence - 1
      acc[currentIndex] += 1
      return acc
    }, Array(18).fill(0))
  }
)

const countActionsByActionType = createSelector(
  [getActionsForIds, getNumOfActionTypes],
  (currentActions, numOfActionTypes) => {
    return currentActions.reduce((acc, action) => {
      const currentActionTypes = action.action_types
      console.assert(
        Array.isArray(currentActionTypes),
        `currentActionTypes expected to be an array but found ${typeof currentActionTypes}`
      )
      if (currentActionTypes && currentActionTypes.length > 0) {
        currentActionTypes.forEach((intActionType) => {
          const indexOfActionType = Number(intActionType) - 1
          console.assert(
            !isNaN(indexOfActionType),
            `indexOfActionType expected to be an integer but found ${indexOfActionType}`
          )
          acc[indexOfActionType] += 1
        })
      }
      return acc
    }, Array(numOfActionTypes).fill(0))
  }
)

const getFormAuthenticityToken = () =>
  window.STATE_FROM_SERVER.formAuthenticityToken
const getFormActionUrl = () => window.STATE_FROM_SERVER.formActionUrl

export {
  getAllTechnicalAreas,
  getAllIndicators,
  getAllActions,
  getActionTypes,
  getNumOfActionTypes,
  getPlanActionIds,
  getPlanGoalMap,
  getActionsForIds,
  getTechnicalAreaMap,
  getIndicatorMap,
  countActionsByTechnicalArea,
  countActionsByActionType,
  getFormAuthenticityToken,
  getFormActionUrl,
}
