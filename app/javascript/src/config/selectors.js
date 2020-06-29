import { createSelector } from "reselect"

const getAllActions = (state) => state.allActions
const getPlanActionIds = (state) => state.planActionIds
const getNumOfActionTypes = (state) => state.nudgesByActionType.length

const getActionsForIds = createSelector(
  [getPlanActionIds, getAllActions],
  (actionIds, actions) => {
    return actions.filter((action) => actionIds.indexOf(action.id) > 0)
  }
)

const countActionsByActionType = createSelector(
  [getActionsForIds, getNumOfActionTypes],
  (currentActions, numOfActionTypes) => {
    return currentActions.reduce((acc, action) => {
      const currentActionTypes = action.action_types
      if (currentActionTypes && currentActionTypes.length > 0) {
        currentActionTypes.forEach((intActionType) => {
          const indexOfActionType = Number(intActionType) - 1
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
  getActionsForIds,
  countActionsByActionType,
  getFormAuthenticityToken,
  getFormActionUrl,
}
