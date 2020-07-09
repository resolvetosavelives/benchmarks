import { createSelector } from "reselect"

const getAllTechnicalAreas = (state) => state.technicalAreas
const getAllIndicators = (state) => state.indicators
const getAllActions = (state) => state.allActions
const getPlanActionIdsByIndicator = (state) => state.planActionIdsByIndicator

const getActionTypes = (state) => state.nudgesByActionType
const getNudgesByActionType = (state) => state.nudgesByActionType
const getNumOfActionTypes = (state) => getActionTypes(state).length

const getSelectedTechnicalAreaId = (state) => state.ui.selectedTechnicalAreaId
const getSelectedActionTypeOrdinal = (state) =>
  state.ui.selectedActionTypeOrdinal

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

const getActionsForIndicator = (actionIdsForIndicator, actions) => {
  return actions.filter(
    (action) => actionIdsForIndicator.indexOf(action.id) >= 0
  )
}

const getSortedActionsForIndicator = (actionsForIndicator) => {
  return actionsForIndicator.sort((actionA, actionB) => {
    const levelA = actionA.disease_id
      ? actionA.disease_id * 1000
      : actionA.level
    const levelB = actionB.disease_id
      ? actionB.disease_id * 1000
      : actionB.level
    const seqA = actionA.sequence
    const seqB = actionB.sequence
    if (levelA < levelB) return -1
    if (levelA > levelB) return 1
    if (seqA < seqB) return -1
    if (seqA > seqB) return 1
    return 0
  })
}

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

// not exported, TODO: get rid of window.STATE_FROM_SERVER
const getDisease = (diseaseId) =>
  window.STATE_FROM_SERVER.diseases.find((disease) => disease.id === diseaseId)

const getDisplayForDiseaseId = (diseaseId) => getDisease(diseaseId).display

const getColorForDiseaseId = (diseaseId) =>
  `color-value-disease-${getDisease(diseaseId).name}`

const getFormAuthenticityToken = () =>
  window.STATE_FROM_SERVER.formAuthenticityToken
const getFormActionUrl = () => window.STATE_FROM_SERVER.formActionUrl

export {
  getAllTechnicalAreas,
  getAllIndicators,
  getAllActions,
  getActionTypes,
  getPlanActionIdsByIndicator,
  getNudgesByActionType,
  getActionsForIndicator,
  getSortedActionsForIndicator,
  getNumOfActionTypes,
  getSelectedTechnicalAreaId,
  getSelectedActionTypeOrdinal,
  getPlanActionIds,
  getPlanGoals,
  getPlanGoalMap,
  getActionsForIds,
  getTechnicalAreaMap,
  getIndicatorMap,
  countActionsByTechnicalArea,
  countActionsByActionType,
  getFormAuthenticityToken,
  getFormActionUrl,
  getDisplayForDiseaseId,
  getColorForDiseaseId,
}
