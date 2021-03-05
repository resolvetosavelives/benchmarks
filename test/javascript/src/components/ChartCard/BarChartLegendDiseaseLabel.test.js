import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import BarChartLegendDiseaseLabel from "components/ChartCard/BarChartLegendDiseaseLabel"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
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

describe("with a disease", () => {
  const disease = { id: 1, name: "influenza", display: "Influenza" }
  beforeEach(() => {
    act(() => {
      ReactDOM.render(
        <BarChartLegendDiseaseLabel disease={disease} />,
        container
      )
    })
  })

  it("displays the correct legend label", () => {
    const li = document.querySelectorAll("li")
    expect(li.length).toEqual(1)
    expect(li[0].className).toMatch("ct-series-influenza")
    expect(li[0].textContent).toMatch("Influenza specific")
  })
})
