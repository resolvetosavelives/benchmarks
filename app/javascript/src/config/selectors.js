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

const getPlan = (state) => state.plan
const getPlanActionIds = (state) => state.planActionIds
const getPlanGoals = (state) => state.planGoals

const getPlanGoalMap = createSelector([getPlanGoals], (goals) => {
  return goals.reduce((acc, goal) => {
    acc[goal.benchmark_indicator_id] = goal
    return acc
  }, {})
})

const getActionsForPlan = createSelector(
  [getPlanActionIds, getAllActions],
  (actionIds, actions) => {
    return actions.filter((action) => actionIds.indexOf(action.id) >= 0)
  }
)

const getActionsForIds = (actionIds, actions) => {
  return actions.filter((action) => actionIds.indexOf(action.id) >= 0)
}

// Sort by disease_id ASC, technical_area.sequence, indicator.sequence ASC, action.level ASC, action.sequence ASC
const getSortedActions = (actions, technicalAreaMap, indicatorMap) => {
  return actions.sort((actionA, actionB) => {
    const diseaseIdA = actionA.disease_id ? actionA.disease_id : 0
    const diseaseIdB = actionB.disease_id ? actionB.disease_id : 0
    if (diseaseIdA < diseaseIdB) return -1
    if (diseaseIdA > diseaseIdB) return 1

    const technicalAreaA = technicalAreaMap[actionA.benchmark_technical_area_id]
    const technicalAreaB = technicalAreaMap[actionB.benchmark_technical_area_id]
    const technicalAreaSeqA = technicalAreaA.sequence
    const technicalAreaSeqB = technicalAreaB.sequence
    if (technicalAreaSeqA < technicalAreaSeqB) return -1
    if (technicalAreaSeqA > technicalAreaSeqB) return 1

    const indicatorA = indicatorMap[actionA.benchmark_indicator_id]
    const indicatorB = indicatorMap[actionB.benchmark_indicator_id]
    const indicatorSeqA = indicatorA.sequence
    const indicatorSeqB = indicatorB.sequence
    if (indicatorSeqA < indicatorSeqB) return -1
    if (indicatorSeqA > indicatorSeqB) return 1

    const levelA = actionA.level
    const levelB = actionB.level
    if (levelA < levelB) return -1
    if (levelA > levelB) return 1

    const seqA = actionA.sequence
    const seqB = actionB.sequence
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
  [getActionsForPlan, getTechnicalAreaMap, getAllTechnicalAreas],
  (currentActions, technicalAreaMap, allTechnicalAreas) => {
    return currentActions.reduce((acc, action) => {
      const technicalArea = technicalAreaMap[action.benchmark_technical_area_id]
      console.assert(
        technicalArea,
        `technicalArea expected but found ${technicalArea}`
      )
      const currentIndex = technicalArea.sequence - 1
      acc[currentIndex] += 1
      return acc
    }, Array(allTechnicalAreas.length).fill(0))
  }
)

const getMatrixOfActionCountsByTechnicalAreaAndDisease = createSelector(
  [getActionsForPlan, getTechnicalAreaMap, getAllTechnicalAreas],
  (currentActions, technicalAreaMap, allTechnicalAreas) => {
    const fnBlankArray = () => Array(allTechnicalAreas.length).fill(0)
    return currentActions.reduce(
      (acc, action) => {
        const technicalArea =
          technicalAreaMap[action.benchmark_technical_area_id]
        console.assert(
          technicalArea,
          `technicalArea expected but found ${technicalArea}`
        )
        const currentIndex = technicalArea.sequence - 1
        if (action.disease_id === 1) {
          acc[1][currentIndex] += 1
        } else {
          acc[0][currentIndex] += 1
        }
        return acc
      },
      [fnBlankArray(), fnBlankArray()]
    )
    // return value:
    //   an array of arrays that each contains TechnicalAreas.length elements full of integers of counts.
    //   the first array is for general actions, the second array is for influenza actions.
  }
)

const countActionsByActionType = createSelector(
  [getActionsForPlan, getNumOfActionTypes],
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
  getSortedActions,
  getNumOfActionTypes,
  getSelectedTechnicalAreaId,
  getSelectedActionTypeOrdinal,
  getPlan,
  getPlanActionIds,
  getPlanGoals,
  getPlanGoalMap,
  getActionsForPlan,
  getActionsForIds,
  getTechnicalAreaMap,
  getIndicatorMap,
  countActionsByTechnicalArea,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  countActionsByActionType,
  getFormAuthenticityToken,
  getFormActionUrl,
  getDisplayForDiseaseId,
  getColorForDiseaseId,
}
