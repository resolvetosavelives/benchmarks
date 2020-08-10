import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import InfoPane from "components/ChartCard/InfoPane"

let container

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

jest.mock("components/ChartCard/ActionCount", () => () => <mock-actioncount />)
jest.mock("components/ChartCard/ClearFilters", () => () => (
  <mock-clearfilters />
))
jest.mock("components/ChartCard/InfluenzaToggle", () => () => (
  <mock-influenzatoggle />
))

describe("InfoPane", () => {
  it("renders with the expected child components", () => {
    act(() => {
      ReactDOM.render(<InfoPane />, container)
    })
    const mockActionCount = container.querySelectorAll("mock-actioncount")
    const mockClearFilter = container.querySelectorAll("mock-clearfilters")
    const mockInfluenzaToggle = container.querySelectorAll(
      "mock-influenzatoggle"
    )

    expect(mockActionCount.length).toEqual(1)
    expect(mockClearFilter.length).toEqual(1)
    expect(mockInfluenzaToggle.length).toEqual(1)
  })
})
