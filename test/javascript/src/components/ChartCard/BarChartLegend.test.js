import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import { getDisplayForDiseaseId } from "config/selectors"
import BarChartLegend from "components/ChartCard/BarChartLegend"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

jest.mock("config/selectors", () => ({
  getDisplayForDiseaseId: jest.fn(),
}))

let container

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("when a plan has no diseases selected", () => {
  beforeEach(() => {
    useSelector.mockReturnValue({
      id: 1,
      disease_ids: [],
    })

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("no legend is displayed", () => {
    expect(container.innerHTML).not.toMatch("ct-legend")
  })
})

describe("when a plan has diseases", () => {
  beforeEach(() => {
    useSelector.mockReturnValue({
      id: 1,
      disease_ids: [1],
    })

    getDisplayForDiseaseId.mockReturnValue("Flu")

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("a legend is displayed with the correct label", () => {
    expect(container.innerHTML).toContain("ct-legend")
    expect(container.innerHTML).toContain("Flu specific")
  })
})
