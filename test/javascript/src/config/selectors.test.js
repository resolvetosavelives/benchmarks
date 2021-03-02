import fs from "fs"
import { beforeAll, describe, expect, it } from "@jest/globals"
import configureStore from "redux-mock-store"
import {
  countActionsByActionType,
  countActionsByTechnicalArea,
  filterActionsForDiseaseId,
  getActionMap,
  getActionsForIds,
  getActionsForPlan,
  getAllActions,
  getAllIndicators,
  getAllTechnicalAreas,
  getIndicatorMap,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getNudgesByActionType,
  getNumOfActionTypes,
  getPlan,
  getPlanActionIds,
  getPlanGoalMap,
  getPlanGoals,
  getSelectedActionTypeOrdinal,
  getSelectedTechnicalAreaId,
  getSortedActions,
  getTechnicalAreaMap,
} from "config/selectors"
import {
  getCountOfPlanActionIds,
  getPlanChartLabels,
  getPlanDiseases,
  makeGetDiseaseForDiseaseId,
  makeGetDiseaseIsShowingForDisease,
} from "../../../../app/javascript/src/config/selectors"
import { CHART_TAB_INDEX_FOR_TECHNICAL_AREA } from "../../../../app/javascript/src/config/constants"

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
      isInfluenzaShowing: true,
      isCholeraShowing: true,
      selectedChartTabIndex: CHART_TAB_INDEX_FOR_TECHNICAL_AREA,
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
      expect(result.length).toEqual(978)
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

  describe("getPlanDiseases", () => {
    it("returns an empty array of diseases for a plan with no diseases", () => {
      const state = store.getState()

      const result = getPlanDiseases(state)

      expect(result).toEqual([])
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
      expect(Object.keys(result).length).toEqual(978)
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
      expect(result.length).toEqual(3)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[2].length).toEqual(18)
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
      expect(result[2]).toEqual([
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
      expect(result.length).toEqual(3)
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

  describe("getCountOfPlanActionIds", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()

      const result = getCountOfPlanActionIds(state)

      expect(result).toEqual(235)
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
    initialStateFromServer.ui = {
      selectedListMode: 213,
      selectedTechnicalAreaId: 11,
      selectedActionTypeOrdinal: 13,
      isInfluenzaShowing: true,
      isCholeraShowing: true,
      selectedChartTabIndex: CHART_TAB_INDEX_FOR_TECHNICAL_AREA,
    }
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
      expect(result.length).toEqual(3)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[2].length).toEqual(18)
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
      expect(result[2]).toEqual([
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
      expect(result.length).toEqual(3)
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

  describe("makeGetDiseaseForDiseaseId", () => {
    it("returns a function that returns the expected string for influenza", () => {
      const state = store.getState()
      const fnResult = makeGetDiseaseForDiseaseId(1)
      const result = fnResult(state)

      expect(result.display).toEqual("Influenza")
    })

    it("returns a function that returns the expected string for cholera", () => {
      const state = store.getState()
      const fnResult = makeGetDiseaseForDiseaseId(2)
      const result = fnResult(state)

      expect(result.display).toEqual("Cholera")
    })
  })

  describe("makeGetDiseaseIsShowingForDisease", () => {
    describe("for influenza", () => {
      const influenza = { id: 1, name: "influenza", display: "Influenza" }

      it("returns a function that returns the default display value", () => {
        const state = store.getState()
        const fnResult = makeGetDiseaseIsShowingForDisease(influenza)
        const result = fnResult(state)

        expect(result).toEqual(true)
      })

      it("returns a function that returns the current display value", () => {
        const state = store.getState()
        state.ui.isInfluenzaShowing = false
        const fnResult = makeGetDiseaseIsShowingForDisease(influenza)
        const result = fnResult(state)

        expect(result).toEqual(false)
      })
    })

    describe("for cholera", () => {
      const cholera = { id: 1, name: "cholera", display: "Cholera" }

      it("returns a function that returns the default display value for cholera", () => {
        const state = store.getState()
        const fnResult = makeGetDiseaseIsShowingForDisease(cholera)
        const result = fnResult(state)

        expect(result).toEqual(true)
      })

      it("returns a function that returns the current display value", () => {
        const state = store.getState()
        state.ui = { isCholeraShowing: false }
        const fnResult = makeGetDiseaseIsShowingForDisease(cholera)
        const result = fnResult(state)

        expect(result).toEqual(false)
      })
    })
  })

  describe("filterActionsForDiseaseId", () => {
    it("returns actions filtered by disease id", () => {
      const actions = [
        { id: 1, disease_id: 1 },
        { id: 2, disease_id: null },
        { id: 3, disease_id: 2 },
        { id: 4, disease_id: 2 },
        { id: 3, disease_id: 3 },
        { id: 4, disease_id: 3 },
        { id: 3, disease_id: 3 },
      ]

      expect(filterActionsForDiseaseId(actions, null)).toEqual([
        {
          id: 2,
          disease_id: null,
        },
      ])
      expect(filterActionsForDiseaseId(actions, 2)).toEqual([
        { id: 3, disease_id: 2 },
        { id: 4, disease_id: 2 },
      ])
    })
  })

  describe("getCountOfPlanActionIds", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()

      const result = getCountOfPlanActionIds(state)

      expect(result).toEqual(283)
    })
  })
})

describe("for a plan that includes influenza and cholera", () => {
  beforeAll(() => {
    const mockStore = configureStore()
    const strStateFromServer = fs.readFileSync(
      `${__dirname}/../../../fixtures/files/state_from_server_with_influenza_and_cholera.json`,
      "utf-8"
    )
    const initialStateFromServer = JSON.parse(strStateFromServer)
    initialStateFromServer.ui = {
      selectedListMode: 213,
      selectedTechnicalAreaId: 11,
      selectedActionTypeOrdinal: 13,
      isInfluenzaShowing: true,
      isCholeraShowing: true,
      selectedChartTabIndex: CHART_TAB_INDEX_FOR_TECHNICAL_AREA,
    }
    store = mockStore(initialStateFromServer)
  })

  describe("getPlanDiseases", () => {
    it("returns an empty array of diseases for a plan with no diseases", () => {
      const state = store.getState()

      const result = getPlanDiseases(state)

      expect(result).toEqual([
        {
          display: "Influenza",
          id: 1,
          name: "influenza",
        },
        {
          display: "Cholera",
          id: 2,
          name: "cholera",
        },
      ])
    })
  })

  describe("getPlanActionIds", () => {
    it("returns the array of all plan IDs", () => {
      const state = store.getState()

      let result = getPlanActionIds(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(327)
    })
  })

  describe("getCountActionsByTechnicalArea", () => {
    it("returns an array of integers, one for each Technical Area, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByTechnicalArea(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(18)
      expect(result).toEqual([
        9,
        19,
        23,
        10,
        12,
        22,
        29,
        8,
        24,
        23,
        22,
        17,
        7,
        31,
        35,
        18,
        14,
        4,
      ])
      expect(result.reduce((acc, r) => acc + r, 0)).toEqual(327)
    })
  })

  describe("getMatrixOfActionCountsByTechnicalAreaAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 18 columns (one per Technical Area)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByTechnicalAreaAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(3)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[2].length).toEqual(18)
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
      expect(result[2]).toEqual([
        1,
        2,
        2,
        0,
        1,
        8,
        7,
        0,
        6,
        1,
        3,
        0,
        0,
        6,
        7,
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
        12,
        53,
        32,
        8,
        14,
        9,
        24,
        60,
        9,
        74,
        15,
        36,
        18,
        10,
        29,
      ])
    })
  })

  describe("getMatrixOfActionCountsByActionTypeAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 15 columns (one per Action Type)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByActionTypeAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(3)
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

  describe("getCountOfPlanActionIds", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()

      const result = getCountOfPlanActionIds(state)

      expect(result).toEqual(327)
    })
  })
})

describe("for a plan that includes influenza and cholera", () => {
  beforeAll(() => {
    const mockStore = configureStore()
    const strStateFromServer = fs.readFileSync(
      `${__dirname}/../../../fixtures/files/state_from_server_with_influenza_and_cholera.json`,
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
      expect(result.length).toEqual(327)
    })
  })

  describe("getCountActionsByTechnicalArea", () => {
    it("returns an array of integers, one for each Technical Area, that sums the actions for each", () => {
      const state = store.getState()
      const result = countActionsByTechnicalArea(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(18)
      expect(result).toEqual([
        9,
        19,
        23,
        10,
        12,
        22,
        29,
        8,
        24,
        23,
        22,
        17,
        7,
        31,
        35,
        18,
        14,
        4,
      ])
      expect(result.reduce((acc, r) => acc + r, 0)).toEqual(327)
    })
  })

  describe("getMatrixOfActionCountsByTechnicalAreaAndDisease", () => {
    it("returns a 2-dimensional array of integers of action counts, two rows (general, influenza) by 18 columns (one per Technical Area)", () => {
      const state = store.getState()
      const result = getMatrixOfActionCountsByTechnicalAreaAndDisease(state)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(3)
      expect(result[0].length).toEqual(18)
      expect(result[1].length).toEqual(18)
      expect(result[2].length).toEqual(18)
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
      expect(result[2]).toEqual([
        1,
        2,
        2,
        0,
        1,
        8,
        7,
        0,
        6,
        1,
        3,
        0,
        0,
        6,
        7,
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
        12,
        53,
        32,
        8,
        14,
        9,
        24,
        60,
        9,
        74,
        15,
        36,
        18,
        10,
        29,
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
        11,
        45,
        27,
        8,
        14,
        9,
        24,
        57,
        6,
        54,
        13,
        36,
        15,
        9,
        27,
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

  describe("makeGetDiseaseForDiseaseId", () => {
    it("returns a function that returns the expected string for influenza", () => {
      const state = store.getState()

      const fnResult = makeGetDiseaseForDiseaseId(1)
      const result = fnResult(state)

      expect(result.display).toEqual("Influenza")
    })

    it("returns a function that returns the expected string for cholera", () => {
      const state = store.getState()

      const fnResult = makeGetDiseaseForDiseaseId(2)
      const result = fnResult(state)

      expect(result.display).toEqual("Cholera")
    })

    it("returns a function that returns undefined", () => {
      const state = store.getState()

      const fnResult = makeGetDiseaseForDiseaseId(0)
      const result = fnResult(state)

      expect(result).toEqual(undefined)
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

  describe("getCountOfPlanActionIds", () => {
    it("returns a function that returns the expected string", () => {
      const state = store.getState()

      const result = getCountOfPlanActionIds(state)

      expect(result).toEqual(327)
    })
  })
})
