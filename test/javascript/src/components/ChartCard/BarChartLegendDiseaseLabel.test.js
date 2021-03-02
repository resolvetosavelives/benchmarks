import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import BarChartLegendDiseaseLabel from "components/ChartCard/BarChartLegendDiseaseLabel"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

jest.mock("config/selectors", () => ({
  makeGetDiseaseForDiseaseId: jest.fn(),
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

describe("when a disease is displayed", () => {
  const diseaseId = 1
  beforeEach(() => {
    useSelector.mockReturnValue({
      id: diseaseId,
      name: "mock-disease-name",
      display: "Mock-Disease-Display",
    })

    act(() => {
      ReactDOM.render(
        <BarChartLegendDiseaseLabel diseaseId={diseaseId} />,
        container
      )
    })
  })

  it("displays the correct legend label", () => {
    const li = document.querySelectorAll("li")
    expect(li.length).toEqual(1)
    expect(li[0].className).toMatch("mock-disease-name")
    expect(li[0].textContent).toMatch("Mock-Disease-Display specific")
  })
})
