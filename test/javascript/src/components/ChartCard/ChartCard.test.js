import { expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import ChartCard from "components/ChartCard/ChartCard"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"

jest.mock("react-redux", () => ({
  useDispatch: jest.fn(),
  useEffect: jest.fn(),
}))
jest.mock("components/ChartCard/BarChartByTechnicalArea", () => () => (
  <mock-BarChartByTechnicalArea />
))
jest.mock("components/ChartCard/BarChartByActionType", () => () => (
  <mock-BarChartByActionType />
))
jest.mock("components/ChartCard/InfoPane", () => () => <mock-InfoPane />)

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("ChartCard has one child BarChartByTechnicalArea component", () => {
  act(() => {
    ReactDOM.render(<ChartCard />, container)
  })

  const mockBarchartbytechnicalarea = container.querySelectorAll(
    "mock-barchartbytechnicalarea"
  )

  expect(mockBarchartbytechnicalarea.length).toEqual(1)
})

it("ChartCard has one child BarChartByActionType component", () => {
  act(() => {
    ReactDOM.render(<ChartCard />, container)
  })

  const mockBarchartbyactiontype = container.querySelectorAll(
    "mock-barchartbyactiontype"
  )

  expect(mockBarchartbyactiontype.length).toEqual(1)
})

it("ChartCard has the expected content children", () => {
  act(() => {
    ReactDOM.render(<ChartCard />, container)
  })

  const elPlanCard = container.querySelectorAll(".plan.card")
  const elTabForTechnicalArea = container.querySelectorAll(
    "#tabForTechnicalArea"
  )
  const elTabForActionType = container.querySelectorAll("#tabForActionType")
  const elTabContentForTechnicalArea = container.querySelectorAll(
    "#tabContentForTechnicalArea"
  )
  const elTabContentForActionType = container.querySelectorAll(
    "#tabContentForActionType"
  )

  expect(elPlanCard.length).toEqual(1)
  expect(elTabForTechnicalArea.length).toEqual(1)
  expect(elTabForActionType.length).toEqual(1)
  expect(elTabContentForTechnicalArea.length).toEqual(1)
  expect(elTabContentForActionType.length).toEqual(1)
})
