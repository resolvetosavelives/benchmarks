import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import PlanEditPage from "components/PlanEditPage"

let container
jest.mock("components/PlanEditForm", () => () => <mock-planeditform />)
container = document.createElement("div")

beforeEach(() => {
  window.STATE_FROM_SERVER = stubStateFromServer()
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
  window.STATE_FROM_SERVER = null
})

it("renders the expected child components", () => {
  act(() => {
    ReactDOM.render(<PlanEditPage />, container)
  })

  expect(container.querySelectorAll("mock-planeditform").length).toEqual(1)
})

function stubStateFromServer() {
  return {
    authenticityToken: "",
    technicalAreas: [],
    indicators: [],
    actions: [],
    planActionIds: [],
    planActionIdsByIndicator: {},
    planActionIdsNotInIndicator: {},
    planChartLabels: [],
    allActions: [],
    selectedTechnicalAreaId: null,
    planGoals: [],
    plan: {},
    nudgesByActionType: {},
    diseases: [],
  }
}
