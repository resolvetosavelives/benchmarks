import fs from "fs"
import { describe, it, expect, beforeAll } from "@jest/globals"
import configureStore from "redux-mock-store"
import {
  getAllActions,
  getPlanActionIds,
  getNumOfActionTypes,
  getActionsForIds,
  countActionsByTechnicalArea,
  countActionsByActionType,
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
    allActions: stateFromServer.actions,
    planActionIds: stateFromServer.planActionIds,
    nudgesByActionType: stateFromServer.nudgesByActionType,
    technicalAreas: stateFromServer.technicalAreas,
  }
  store = mockStore(initialState)
})

describe("getAllActions", () => {
  it("returns the array of all actions", () => {
    const state = store.getState()

    const result = getAllActions(state)

    expect(result).toBeInstanceOf(Array)
    expect(result.length).toEqual(876)
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

describe("countActionsByTechnicalArea", () => {
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
