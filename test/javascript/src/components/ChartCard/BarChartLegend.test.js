import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import BarChartLegend from "components/ChartCard/BarChartLegend"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

jest.mock("components/ChartCard/BarChartLegendDiseaseLabel", () => () => (
  <div className="mock-bar-chart-legend-disease-label" />
))

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
    useSelector.mockReturnValue({ id: 1, disease_ids: [] })

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("displays the default Health Security and one disease legend label", () => {
    const li = document.querySelectorAll("li")
    const barChartLegendEl = document.querySelectorAll(
      "div.mock-bar-chart-legend-disease-label"
    )

    expect(li.length).toEqual(1)
    expect(li[0].textContent).toEqual("Health security")
    expect(barChartLegendEl.length).toEqual(0)
  })
})

describe("when a plan has diseases selected", () => {
  beforeEach(() => {
    useSelector.mockReturnValue({ id: 1, disease_ids: [1, 2] })

    act(() => {
      ReactDOM.render(<BarChartLegend />, container)
    })
  })

  it("displays two legend labels", () => {
    const li = document.querySelectorAll("li")
    const barChartLegendEl = document.querySelectorAll(
      "div.mock-bar-chart-legend-disease-label"
    )

    expect(li.length).toEqual(1)
    expect(li[0].textContent).toEqual("Health security")
    expect(barChartLegendEl.length).toEqual(2)
  })
})
