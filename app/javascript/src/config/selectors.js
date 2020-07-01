import { createSelector } from "reselect"

const getAllActions = (state) => state.allActions
const getPlanActionIds = (state) => state.planActionIds
const getNumOfActionTypes = (state) => state.nudgesByActionType.length
const getTechnicalAreas = (state) => state.technicalAreas

const getActionsForIds = createSelector(
  [getPlanActionIds, getAllActions],
  (actionIds, actions) => {
    return actions.filter((action) => actionIds.indexOf(action.id) >= 0)
  }
)

const technicalAreaMap = createSelector(
  [getTechnicalAreas],
  (technicalAreas) => {
    return technicalAreas.reduce((map, technicalArea) => {
      map[technicalArea.id] = technicalArea
      return map
    }, {})
  }
)

const countActionsByTechnicalArea = createSelector(
  [getActionsForIds, technicalAreaMap],
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
  getAllActions,
  getPlanActionIds,
  getNumOfActionTypes,
  getActionsForIds,
  countActionsByTechnicalArea,
  countActionsByActionType,
  getFormAuthenticityToken,
  getFormActionUrl,
}
