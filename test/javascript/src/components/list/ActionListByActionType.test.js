import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import ActionListByActionType from "components/list/ActionListByActionType"

jest.mock("components/list/Action", () => () => <mock-action />)
jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
  const selectedActionTypeOrdinal = 3
  const action1 = { id: 17, action_types: null }
  const action2 = { id: 19, action_types: [selectedActionTypeOrdinal] }
  const action3 = { id: 37, action_types: [3, selectedActionTypeOrdinal] }
  const action4 = { id: 41, action_types: [3, 17, selectedActionTypeOrdinal] }
  const action5 = { id: 47, action_types: [] }
  const action6 = { id: 53, action_types: [selectedActionTypeOrdinal] }
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
  useSelector
    .mockImplementationOnce((callback) =>
      callback({
        // action6 intentionally omitted from next line because in this exmaple it does not belong to the plan
        planActionIds: [
          action1.id,
          action2.id,
          action3.id,
          action4.id,
          action5.id,
        ],
      })
    )
    .mockImplementationOnce((callback) => {
      const actions = {}
      actions[action1.id] = action1
      actions[action2.id] = action2
      actions[action3.id] = action3
      actions[action4.id] = action4
      actions[action5.id] = action5
      actions[action6.id] = action6
      return callback({
        actions: actions,
      })
    })
    .mockImplementationOnce((callback) =>
      callback({
        selectedActionTypeOrdinal: selectedActionTypeOrdinal,
      })
    )
    .mockImplementationOnce((cb) => cb({ planChartLabels: planChartLabels }))
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("when passed 3 Action Ids it renders 3 Action component children", () => {
  act(() => {
    ReactDOM.render(<ActionListByActionType />, container)
  })
  const foundActionListByActionTypeComponents = container.querySelectorAll(
    "mock-action"
  )

  expect(foundActionListByActionTypeComponents.length).toEqual(3)
})
