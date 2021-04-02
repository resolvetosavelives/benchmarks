import { createSelector } from "reselect"

const getAllTechnicalAreas = (state) => state.technicalAreas
const getAllIndicators = (state) => state.indicators
const getAllActions = (state) => state.actions
const getAllDiseases = (state) => state.diseases
const getPlanActionIdsByIndicator = (state) => state.planActionIdsByIndicator

const getNudgesByActionType = (state) => state.nudgesByActionType
const getNumOfActionTypes = (state) => getNudgesByActionType(state).length

const getSelectedTechnicalAreaId = (state) => state.ui.selectedTechnicalAreaId
const getSelectedActionTypeOrdinal = (state) =>
  state.ui.selectedActionTypeOrdinal
const getSelectedChartTabIndex = (state) => state.ui.selectedChartTabIndex

const getPlan = (state) => state.plan
const getPlanActionIds = (state) => state.planActionIds
const getPlanGoals = (state) => state.planGoals
const getPlanChartLabels = (state) => state.planChartLabels
const getCountOfPlanActionIds = (state) => getPlanActionIds(state).length
const getUi = (state) => state.ui

const getPlanDiseases = createSelector(
  [getPlan, getAllDiseases],
  (plan, diseases) =>
    plan.disease_ids.map((diseaseId) => getDisease(diseases, diseaseId))
)

const getPlanGoalMap = createSelector([getPlanGoals], (goals) => {
  return goals.reduce((acc, goal) => {
    acc[goal.benchmark_indicator_id] = goal
    return acc
  }, {})
})

const getActionMap = createSelector([getAllActions], (allActions) => {
  return allActions.reduce((map, action) => {
    map[action.id] = action
    return map
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

// Sort by: disease_id ASC, technical_area.sequence ASC, indicator.sequence ASC, action.level ASC, action.sequence ASC
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
  [getPlan, getActionsForPlan, getTechnicalAreaMap, getAllTechnicalAreas],
  (plan, currentActions, technicalAreaMap, allTechnicalAreas) => {
    const fnBlankArray = () => Array(allTechnicalAreas.length).fill(0)
    return currentActions.reduce(
      (acc, action) => {
        const technicalArea =
          technicalAreaMap[action.benchmark_technical_area_id]
        const currentIndex = technicalArea.sequence - 1
        switch (action.disease_id) {
          case 1:
          case 2:
            if (plan.disease_ids.includes(action.disease_id)) {
              acc[action.disease_id][currentIndex] += 1
            }
            break
          default:
            acc[0][currentIndex] += 1
        }
        return acc
      },
      [fnBlankArray(), fnBlankArray(), fnBlankArray()]
    )
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

const getMatrixOfActionCountsByActionTypeAndDisease = createSelector(
  [getActionsForPlan, getNumOfActionTypes],
  (planActions, numOfActionTypes) => {
    const fnBlankArray = () => Array(numOfActionTypes).fill(0)
    return planActions.reduce(
      (acc, action) => {
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
            if (acc[action.disease_id]) {
              acc[action.disease_id][indexOfActionType] += 1
            } else {
              acc[0][indexOfActionType] += 1
            }
          })
        }
        return acc
      },
      [fnBlankArray(), fnBlankArray(), fnBlankArray(), fnBlankArray()]
    )
  }
)

const getDisease = (diseases, diseaseId) =>
  diseases.find((disease) => disease.id === diseaseId)

const makeGetDiseaseForDiseaseId = (diseaseId) =>
  createSelector([getAllDiseases], (diseases) => {
    return getDisease(diseases, diseaseId)
  })

const makeGetDiseaseIsShowingForDisease = (disease) =>
  createSelector([getUi], (ui) => {
    const propertyName = `is${disease.display}Showing`
    return ui[propertyName]
  })

const getFormAuthenticityToken = () =>
  window.STATE_FROM_SERVER.formAuthenticityToken
const getFormActionUrl = () => window.STATE_FROM_SERVER.formActionUrl

const filterActionsForDiseaseId = (actions, diseaseId) => {
  return actions.filter((action) => action.disease_id === diseaseId)
}

export {
  countActionsByActionType,
  countActionsByTechnicalArea,
  filterActionsForDiseaseId,
  getActionMap,
  getActionsForIds,
  getActionsForPlan,
  getAllActions,
  getAllDiseases,
  getAllIndicators,
  getAllTechnicalAreas,
  getCountOfPlanActionIds,
  getDisease,
  getFormActionUrl,
  getFormAuthenticityToken,
  getIndicatorMap,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getNudgesByActionType,
  getNumOfActionTypes,
  getPlan,
  getPlanActionIds,
  getPlanActionIdsByIndicator,
  getPlanChartLabels,
  getPlanDiseases,
  getPlanGoalMap,
  getPlanGoals,
  getSelectedActionTypeOrdinal,
  getSelectedChartTabIndex,
  getSelectedTechnicalAreaId,
  getSortedActions,
  getTechnicalAreaMap,
  getUi,
  makeGetDiseaseForDiseaseId,
  makeGetDiseaseIsShowingForDisease,
}
