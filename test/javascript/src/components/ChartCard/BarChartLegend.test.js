import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import BarChartLegend from "components/ChartCard/BarChartLegend"
import { makeGetDisplayForDiseaseId } from "config/selectors"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

jest.mock("config/selectors", () => ({
  makeGetDisplayForDiseaseId: jest.fn(),
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
    makeGetDisplayForDiseaseId.mockReturnValueOnce(jest.fn())
    useSelector
      .mockReturnValueOnce({
        id: 1,
        disease_ids: [],
      })
      .mockReturnValueOnce(undefined)

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("displays no legend", () => {
    expect(container.innerHTML).not.toMatch("ct-legend")
  })
})

describe("when a plan has diseases", () => {
  beforeEach(() => {
    makeGetDisplayForDiseaseId.mockReturnValueOnce(
      jest.fn().mockReturnValueOnce([])
    )
    useSelector
      .mockReturnValueOnce({
        id: 1,
        disease_ids: [1],
      })
      .mockReturnValueOnce("Influenza")

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("displays a legend with the correct label", () => {
    expect(container.innerHTML).toContain("ct-legend")
    expect(container.innerHTML).toContain("Influenza specific")
  })
})
