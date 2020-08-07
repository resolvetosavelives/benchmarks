import fs from "fs"
import { beforeAll, describe, expect, it } from "@jest/globals"
import configureStore from "redux-mock-store"
import {
  getAllTechnicalAreas,
  getAllIndicators,
  getAllActions,
  getNudgesByActionType,
  getSelectedTechnicalAreaId,
  getSelectedActionTypeOrdinal,
  countActionsByActionType,
  countActionsByTechnicalArea,
  getActionsForIds,
  getActionsForPlan,
  getIndicatorMap,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getNumOfActionTypes,
  getPlan,
  getActionMap,
  getPlanActionIds,
  getPlanGoals,
  getPlanGoalMap,
  getSortedActions,
  getTechnicalAreaMap,
  isPlanInfluenza,
  makeGetDisplayForDiseaseId,
  filterOutInfluenzaActions,
  getIsInfluenzaShowing,
} from "config/selectors"
import { getPlanChartLabels } from "../../../../app/javascript/src/config/selectors"

let store

describe("for a plan without any specific diseases", () => {
  beforeAll(() => {
    const mockStore = configureStore()
    const strStateFromServer = fs.readFileSync(
      `${__dirname}/../../../fixtures/files/state_from_server.json`,
      "utf-8"
    )
    const initialStateFromServer = JSON.parse(strStateFromServer)
    initialStateFromServer.ui = {
      selectedListMode: 213,
      selectedTechnicalAreaId: 11,
      selectedActionTypeOrdinal: 13,
    }
    store = mockStore(initialStateFromServer)
  })

  describe("getAllTechnicalAreas", () => {
    it("returns the array of all TechnicalAreas", () => {
      const state = store.getState()

      const result = getAllTechnicalAreas(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(18)
    })
  })

  describe("getAllIndicators", () => {
    it("returns the array of all indicators", () => {
      const state = store.getState()

      const result = getAllIndicators(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(44)
    })
  })

  describe("getAllActions", () => {
    it("returns the array of all actions", () => {
      const state = store.getState()

      const result = getAllActions(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(929)
    })
  })

  describe("getNudgesByActionType", () => {
    it("returns the array of all actions", () => {
      const state = store.getState()

      const result = getNudgesByActionType(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(15)
    })
  })

  describe("getSelectedTechnicalAreaId", () => {
    it("returns the array of all actions", () => {
      const state = store.getState()

      const result = getSelectedTechnicalAreaId(state)

      expect(result).toEqual(11)
    })
  })

  describe("getSelectedActionTypeOrdinal", () => {
    it("returns the array of all actions", () => {
      const state = store.getState()

      const result = getSelectedActionTypeOrdinal(state)

      expect(result).toEqual(13)
    })
  })

  describe("getSortedActions", () => {
    let technicalAreaMap, indicatorMap, actionsToSort, sortedActions

    beforeEach(() => {
      const state = store.getState()
      const actionIdsToSort = [
        // These ids are copied from the actions that are displayed when you go to Action Type tab
        // and then the Assessment and Data Use bar. These ids will likely change when more Health security actions
        // or other disease specific actions are added in a later phase, and you will need to update the test
        888,
        2,
        100,
        892,
        124,
        144,
        146,
        186,
        217,
        218,
        234,
        257,
        297,
        298,
        370,
        371,
        373,
        393,
        926,
        885,
        499,
        886,
        569,
        570,
        904,
        571,
        899,
        900,
        592,
        594,
        636,
        727,
        744,
        769,
        770,
        773,
        785,
        786,
        787,
        788,
        829,
        830,
        831,
        835,
        850,
        854,
      ]
      const actions = getAllActions(state)
      actionsToSort = getActionsForIds(actionIdsToSort, actions)
      technicalAreaMap = getTechnicalAreaMap(state)
      indicatorMap = getIndicatorMap(state)
    })

    it("returns actions sorted by disease, technical area sequence, indicator sequence, action level, and action sequence", () => {
      sortedActions = getSortedActions(
        actionsToSort,
        technicalAreaMap,
        indicatorMap
      )
      const sortedActionIds = [
        2,
        100,
        124,
        144,
        146,
        186,
        217,
        218,
        234,
        257,
        297,
        298,
        370,
        371,
        373,
        393,
        499,
        569,
        570,
        571,
        592,
        594,
        636,
        727,
        744,
        769,
        770,
        773,
        785,
        786,
        787,
        788,
        829,
        830,
        831,
        835,
        850,
        854,
        888,
        892,
        926,
        885,
        886,
        904,
        899,
        900,
      ]
      expect(sortedActions.map((action) => action.id)).toEqual(sortedActionIds)
    })
  })

  describe("getTechnicalAreaMap", () => {
    it("returns a hash map of technicalArea.id => technicalArea", () => {
      const state = store.getState()

      const result = getTechnicalAreaMap(state)

      expect(result).toBeInstanceOf(Object)
      expect(result[3].id).toEqual(3)
      expect(result[3].sequence).toEqual(3)
      expect(result[3].text).toEqual("Antimicrobial Resistance")
    })
  })

  describe("getIndicatorMap", () => {
    it("returns a hash map of indicator.id => indicator", () => {
      const state = store.getState()

      const result = getIndicatorMap(state)

      expect(result).toBeInstanceOf(Object)
      expect(result[2].id).toEqual(2)
      expect(result[2].sequence).toEqual(2)
      expect(result[2].text).toEqual(
        "Financing is available for the implementation of IHR capacities"
      )
      expect(result[2].objective).toEqual(
        "To ensure financing is available for the implementation of IHR capacities"
      )
    })
  })

  describe("getPlanGoalMap", () => {
    it("returns a hash map of goal.id => goal", () => {
      const state = store.getState()

      const result = getPlanGoalMap(state)

      expect(result).toBeInstanceOf(Object)
      expect(result[1]).toBeInstanceOf(Object)
      expect(result[1].id).not.toBeNull()
      expect(result[1].plan_id).not.toBeNull()
      expect(result[1].value).not.toBeNull()
      expect(result[1].benchmark_indicator_id).not.toBeNull()
    })
  })

  describe("getPlan", () => {
    it("returns the plan", () => {
      const state = store.getState()

      let plan = getPlan(state)

      expect(plan).toBeInstanceOf(Object)
      expect(typeof plan.id).toEqual("number")
      expect(typeof plan.name).toEqual("string")
      expect(typeof plan.term).toEqual("number")
      expect(plan.disease_ids).toBeInstanceOf(Array)
    })
  })

  describe("getPlanActionIds", () => {
    it("returns the array of all plan IDs", () => {
      const state = store.getState()

      let result = getPlanActionIds(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(235)
    })
  })

  describe("getPlanGoals", () => {
    it("returns the array of all plan IDs", () => {
      const state = store.getState()

      let result = getPlanGoals(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(39)
    })
  })

  describe("getPlanChartLabels", () => {
    it("returns the array of arrays of chart labels", () => {
      const state = store.getState()

      let result = getPlanChartLabels(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(2)
      expect(result[0]).toBeInstanceOf(Array)
      expect(result[1]).toBeInstanceOf(Array)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(15)
    })
  })

  describe("getActionMap", () => {
    it("returns the array of all plan IDs", () => {
      const state = store.getState()

      let result = getActionMap(state)

      expect(result).toBeInstanceOf(Object)
      expect(Object.keys(result).length).toEqual(929)
    })
  })

  describe("getNumOfActionTypes", () => {
    it("returns the integer count of action types", () => {
      const state = store.getState()

      let result = getNumOfActionTypes(state)

      expect(result).toEqual(15)
    })
  })

  describe("getActionsForPlan", () => {
    it("returns an array of all action objects for the plan", () => {
      const state = store.getState()

      const result = getActionsForPlan(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(235)
      expect(result[0]).toBeInstanceOf(Object)
    })
  })

  describe("getActionsForIds", () => {
    it("returns an array of action objects for the given actionIds", () => {
      const actions = [
        { id: 1, level: 2, sequence: 2, disease_id: null },
        { id: 2, level: 2, sequence: 1, disease_id: null },
        { id: 3, level: 1, sequence: 2, disease_id: null },
        { id: 4, level: 1, sequence: 1, disease_id: null },
      ]
      const actionIds = [1, 3]

      const actionsForIds = getActionsForIds(actionIds, actions)

      expect(actionsForIds.length).toEqual(2)
      expect(actionsForIds.map((a) => a.id)).toEqual([1, 3])
    })
  })

  describe("getCountActionsByTechnicalArea", () => {
    it("returns an array of integers, one for each Technical Area, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByTechnicalArea(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(18)
      expect(result).toEqual([
        6,
        12,
        19,
        9,
        11,
        13,
        19,
        7,
        15,
        18,
        11,
        15,
        7,
        19,
        20,
        16,
        14,
        4,
      ])
      expect(result.reduce((acc, r) => acc + r, 0)).toEqual(235)
    })
  })

  describe("getMatrixOfActionCountsByTechnicalAreaAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 18 columns (one per Technical Area)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByTechnicalAreaAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(2)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[0]).toEqual([
        6,
        12,
        19,
        9,
        11,
        13,
        19,
        7,
        15,
        18,
        11,
        15,
        7,
        19,
        20,
        16,
        14,
        4,
      ])
      expect(result[1]).toEqual([
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ])
    })
  })

  describe("countActionsByActionType", () => {
    it("returns an array of integers, one for each Action Type, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByActionType(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(15)
      expect(result).toEqual([
        8,
        40,
        23,
        7,
        9,
        9,
        20,
        45,
        2,
        45,
        13,
        32,
        8,
        3,
        23,
      ])
    })
  })

  describe("getMatrixOfActionCountsByActionTypeAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 15 columns (one per Action Type)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByActionTypeAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(2)
      expect(result[0].length).toEqual(15)
      expect(result[1].length).toEqual(15)
      expect(result[0]).toEqual([
        8,
        40,
        23,
        7,
        9,
        9,
        20,
        45,
        2,
        45,
        13,
        32,
        8,
        3,
        23,
      ])
      expect(result[1]).toEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    })
  })

  describe("isPlanInfluenza", () => {
    it("returns false", () => {
      const state = store.getState()

      let result = isPlanInfluenza(state)

      expect(result).toEqual(false)
    })
  })

  describe("makeGetDisplayForDiseaseId", () => {
    it("returns a function that returns empty string", () => {
      const state = store.getState()

      const fnResult = makeGetDisplayForDiseaseId([])
      const result = fnResult(state)

      expect(result).toEqual("")
    })
  })
})

describe("for a plan that includes influenza", () => {
  beforeAll(() => {
    const mockStore = configureStore()
    const strStateFromServer = fs.readFileSync(
      `${__dirname}/../../../fixtures/files/state_from_server_with_influenza.json`,
      "utf-8"
    )
    const initialStateFromServer = JSON.parse(strStateFromServer)
    store = mockStore(initialStateFromServer)
  })

  describe("getPlanActionIds", () => {
    it("returns the array of all plan IDs", () => {
      const state = store.getState()

      let result = getPlanActionIds(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(283)
    })
  })

  describe("getCountActionsByTechnicalArea", () => {
    it("returns an array of integers, one for each Technical Area, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByTechnicalArea(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(18)
      expect(result).toEqual([
        8,
        17,
        21,
        10,
        11,
        14,
        22,
        8,
        18,
        22,
        19,
        17,
        7,
        25,
        28,
        18,
        14,
        4,
      ])
      expect(result.reduce((acc, r) => acc + r, 0)).toEqual(283)
    })
  })

  describe("getMatrixOfActionCountsByTechnicalAreaAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 18 columns (one per Technical Area)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByTechnicalAreaAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(2)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[0]).toEqual([
        6,
        12,
        19,
        9,
        11,
        13,
        19,
        7,
        15,
        18,
        11,
        15,
        7,
        19,
        20,
        16,
        14,
        4,
      ])
      expect(result[1]).toEqual([
        2,
        5,
        2,
        1,
        0,
        1,
        3,
        1,
        3,
        4,
        8,
        2,
        0,
        6,
        8,
        2,
        0,
        0,
      ])
    })
  })

  describe("countActionsByActionType", () => {
    it("returns an array of integers, one for each Action Type, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByActionType(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(15)
      expect(result).toEqual([
        9,
        48,
        28,
        7,
        9,
        9,
        20,
        48,
        5,
        65,
        15,
        32,
        11,
        4,
        25,
      ])
    })
  })

  describe("getMatrixOfActionCountsByActionTypeAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 15 columns (one per Action Type)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByActionTypeAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(2)
      expect(result[0].length).toEqual(15)
      expect(result[1].length).toEqual(15)
      expect(result[0]).toEqual([
        8,
        40,
        23,
        7,
        9,
        9,
        20,
        45,
        2,
        45,
        13,
        32,
        8,
        3,
        23,
      ])
      expect(result[1]).toEqual([1, 8, 5, 0, 0, 0, 0, 3, 3, 20, 2, 0, 3, 1, 2])
    })
  })

  describe("isPlanInfluenza", () => {
    it("returns true", () => {
      const state = store.getState()

      let result = isPlanInfluenza(state)

      expect(result).toEqual(true)
    })
  })

  describe("makeGetDisplayForDiseaseId", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()

      const fnResult = makeGetDisplayForDiseaseId([1])
      const result = fnResult(state)

      expect(result).toEqual("Influenza")
    })
  })

  describe("filterOutInfluenzaActions", () => {
    it("returns a function that returns the expected string", () => {
      const actionsToFilter = [
        { id: 1, disease_id: 12 },
        { id: 2, disease_id: undefined },
        { id: 3, disease_id: 17 },
        { id: 4, disease_id: null },
      ]
      const result = filterOutInfluenzaActions(actionsToFilter)

      expect(result.length).toEqual(2)
    })
  })

  describe("getIsInfluenzaShowing", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()
      state.ui = {}
      state.ui.isInfluenzaShowing = true

      const result = getIsInfluenzaShowing(state)

      expect(result).toBeTruthy()
    })
  })
})
