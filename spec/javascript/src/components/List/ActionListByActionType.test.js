import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import ActionListByActionType from "components/List/ActionListByActionType"
import * as selectors from "config/selectors"

jest.mock("components/List/Action", () => () => <mock-action />)
jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

let container, spyGetSortedActions

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
  const selectedActionTypeOrdinal = 3
  const action1 = {
    id: 17,
    action_types: null,
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  const action2 = {
    id: 19,
    action_types: [selectedActionTypeOrdinal],
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  const action3 = {
    id: 37,
    action_types: [3, selectedActionTypeOrdinal],
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  const action4 = {
    id: 41,
    action_types: [3, 17, selectedActionTypeOrdinal],
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  const action5 = {
    id: 47,
    action_types: [],
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  const action6 = {
    id: 53,
    action_types: [selectedActionTypeOrdinal],
    benchmark_technical_area_id: 1,
    benchmark_indicator_id: 1,
  }
  // TODO: factor out this planChartLabels data to DRY up this and other uses prob into a file instead.
  const planChartLabels = [
    [
      "Legislation",
      "IHR coordination",
      "AMR",
      "Zoonotic disease",
      "Food safety",
      "Immunization",
      "Laboratory",
      "Biosafety \u0026 biosecurity",
      "Surveillance",
      "Human resources",
      "Preparedness",
      "Rapid response",
      "Linking public health",
      "Medical countermeasures",
      "Risk communication",
      "Points of entry",
      "Chemical events",
      "Radiation",
    ],
    [
      "Advocacy",
      "Assessment and Data Use",
      "Coordination",
      "Designation",
      "Dissemination",
      "Financing",
      "Monitoring and Evaluation",
      "Planning and Strategy",
      "Procurement",
      "Program Implementation",
      "SimEx and AAR",
      "SOPs",
      "Surveillance",
      "Tool Development",
      "Training",
    ],
  ]
  let mockPlanActionIds = [
    action1.id,
    action2.id,
    action3.id,
    action4.id,
    action5.id,
    // action6 intentionally omitted from next line because in this example it does not belong to the plan
  ]
  const mockActionMap = {
    [action1.id]: action1,
    [action2.id]: action2,
    [action3.id]: action3,
    [action4.id]: action4,
    [action5.id]: action5,
    [action6.id]: action6,
  }
  const mockActions = [action1, action2, action3, action4, action5, action6]
  const mockTechnicalAreaMap = { 1: {} }
  const indicatorMap = { 1: {} }

  useSelector
    .mockReturnValueOnce(mockPlanActionIds)
    .mockReturnValueOnce(mockActionMap)
    .mockReturnValueOnce(selectedActionTypeOrdinal)
    .mockReturnValueOnce(mockActions)
    .mockReturnValueOnce(mockTechnicalAreaMap)
    .mockReturnValueOnce(indicatorMap)
    .mockReturnValueOnce(planChartLabels)

  spyGetSortedActions = jest.spyOn(selectors, "getSortedActions")
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("it renders 3 sorted Action component children", () => {
  act(() => {
    ReactDOM.render(<ActionListByActionType />, container)
  })
  const foundActionListByActionTypeComponents =
    container.querySelectorAll("mock-action")
  expect(foundActionListByActionTypeComponents.length).toEqual(3)
  expect(spyGetSortedActions).toHaveBeenCalled()
})
