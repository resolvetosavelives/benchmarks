import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import InfoPane from "components/ChartCard/InfoPane"

let container

jest.mock("components/ChartCard/ActionCount", () => () => <mock-actioncount />)
jest.mock("components/ChartCard/ClearFilters", () => () => (
  <mock-clearfilters />
))
jest.mock("components/ChartCard/DiseaseToggles", () => () => (
  <mock-diseasetoggles />
))
jest.mock("components/ChartCard/BarChartLegend", () => () => (
  <mock-barchartlegend />
))

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("InfoPane", () => {
  it("renders with the expected child components", () => {
    act(() => {
      ReactDOM.render(<InfoPane />, container)
    })

    const mockActionCount = container.querySelectorAll("mock-actioncount")
    const mockClearFilter = container.querySelectorAll("mock-clearfilters")
    const mockDiseaseToggles = container.querySelectorAll("mock-diseasetoggles")
    const mockBarChartLegend = container.querySelectorAll("mock-barchartlegend")

    expect(mockActionCount.length).toEqual(1)
    expect(mockClearFilter.length).toEqual(1)
    expect(mockDiseaseToggles.length).toEqual(1)
    expect(mockBarChartLegend.length).toEqual(1)
  })
})
