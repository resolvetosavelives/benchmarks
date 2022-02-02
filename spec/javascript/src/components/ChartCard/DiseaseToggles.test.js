import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import DiseaseToggles from "components/ChartCard/DiseaseToggles"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/ChartCard/DiseaseToggle", () => () => (
  <mock-DiseaseToggle />
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

describe("with a plan with diseases", () => {
  beforeEach(() => {
    useSelector.mockReturnValue([
      {
        display: "Influenza",
        id: 1,
        name: "influenza",
      },
      {
        display: "Cholera",
        id: 2,
        name: "cholera",
      },
    ])

    act(() => {
      ReactDOM.render(<DiseaseToggles />, container)
    })
  })

  it("displays the same number of DiseaseToggle components as there are diseases", () => {
    const foundDiseaseToggleComponents =
      container.querySelectorAll("mock-DiseaseToggle")
    expect(foundDiseaseToggleComponents.length).toEqual(2)
  })
})

describe("with a plan with no diseases", () => {
  beforeEach(() => {
    useSelector.mockReturnValue([])

    act(() => {
      ReactDOM.render(<DiseaseToggles />, container)
    })
  })

  it("displays no DiseaseToggle components", () => {
    const foundDiseaseToggleComponents =
      container.querySelectorAll("mock-DiseaseToggle")
    expect(foundDiseaseToggleComponents.length).toEqual(0)
  })
})
