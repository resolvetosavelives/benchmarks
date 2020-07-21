import fs from "fs"
import { describe, it, expect, beforeAll } from "@jest/globals"
import configureStore from "redux-mock-store"
import {
  getAllActions,
  getPlan,
  getPlanActionIds,
  getNumOfActionTypes,
  getActionsForIds,
  getTechnicalAreaMap,
  getIndicatorMap,
  getPlanGoalMap,
  countActionsByTechnicalArea,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  countActionsByActionType,
  getSortedActionsForIndicator,
} from "config/selectors"

let store
beforeAll(() => {
  const mockStore = configureStore()
  const strStateFromServer = fs.readFileSync(
    `${__dirname}/../../../fixtures/files/state_from_server.json`,
    "utf-8"
  )
  const stateFromServer = JSON.parse(strStateFromServer)
  const initialState = {
    plan: stateFromServer.plan,
    allActions: stateFromServer.actions,
    planActionIds: stateFromServer.planActionIds,
    nudgesByActionType: stateFromServer.nudgesByActionType,
    technicalAreas: stateFromServer.technicalAreas,
    indicators: stateFromServer.indicators,
    planGoals: stateFromServer.planGoals,
  }
  store = mockStore(initialState)
})

describe("getAllActions", () => {
  it("returns the array of all actions", () => {
    const state = store.getState()

    const result = getAllActions(state)

    expect(result).toBeInstanceOf(Array)
    expect(result.length).toEqual(929)
  })
})

describe("getSortedActionsForIndicator", () => {
  describe("when there are no disease specific actions", () => {
    const actionsToSort = [
      { id: 1, level: 2, sequence: 2, disease_id: null },
      { id: 2, level: 2, sequence: 1, disease_id: null },
      { id: 3, level: 1, sequence: 2, disease_id: null },
      { id: 4, level: 1, sequence: 1, disease_id: null },
    ]
    it("returns the actions sorted by level then sequence", () => {
      const sortedActions = getSortedActionsForIndicator(actionsToSort)
      expect(sortedActions).toEqual([
        { id: 4, level: 1, sequence: 1, disease_id: null },
        { id: 3, level: 1, sequence: 2, disease_id: null },
        { id: 2, level: 2, sequence: 1, disease_id: null },
        { id: 1, level: 2, sequence: 2, disease_id: null },
      ])
    })
  })
  describe("when there are disease specific actions", () => {
    const actionsToSort = [
      { id: 7, level: null, sequence: 2, disease_id: 2 },
      { id: 8, level: null, sequence: 1, disease_id: 2 },
      { id: 5, level: null, sequence: 2, disease_id: 1 },
      { id: 6, level: null, sequence: 1, disease_id: 1 },
      { id: 1, level: 2, sequence: 2, disease_id: null },
      { id: 2, level: 2, sequence: 1, disease_id: null },
      { id: 3, level: 1, sequence: 2, disease_id: null },
      { id: 4, level: 1, sequence: 1, disease_id: null },
    ]
    it("returns the actions sorted by level then sequence and with disease specific actions last and in disease then sequence order", () => {
      const sortedActions = getSortedActionsForIndicator(actionsToSort)
      expect(sortedActions).toEqual([
        { id: 4, level: 1, sequence: 1, disease_id: null },
        { id: 3, level: 1, sequence: 2, disease_id: null },
        { id: 2, level: 2, sequence: 1, disease_id: null },
        { id: 1, level: 2, sequence: 2, disease_id: null },
        { id: 6, level: null, sequence: 1, disease_id: 1 },
        { id: 5, level: null, sequence: 2, disease_id: 1 },
        { id: 8, level: null, sequence: 1, disease_id: 2 },
        { id: 7, level: null, sequence: 2, disease_id: 2 },
      ])
    })
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

describe("getNumOfActionTypes", () => {
  it("returns the integer count of action types", () => {
    const state = store.getState()

    let result = getNumOfActionTypes(state)

    expect(result).toEqual(15)
  })
})

describe("getActionsForIds", () => {
  it("returns an array of action objects for the given action IDs", () => {
    const state = store.getState()

    const result = getActionsForIds(state)

    expect(result).toBeInstanceOf(Array)
    expect(result.length).toEqual(235)
    expect(result[0]).toBeInstanceOf(Object)
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
  it("returns a 2-dimensional array of integers of action counts, two rows (general, influeza) by 18 columns (one per Technical Area)", () => {
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

describe("getSortedActionsForIndicator", () => {
  it("returns an array of integers, one for each Action Type, that sums the actions for each", () => {
    // const state = store.getState()
    const arrayOfActionsToBeSorted = []
    const result = getSortedActionsForIndicator(arrayOfActionsToBeSorted)

    expect(result).toBeInstanceOf(Array)
  })
})
