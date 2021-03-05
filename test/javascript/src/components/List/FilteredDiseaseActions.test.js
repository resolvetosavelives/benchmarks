import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import FilteredDiseaseActions from "components/List/FilteredDiseaseActions"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/List/Action", () => () => <mock-Action />)

let container, actions

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("with actions", () => {
  const disease = { id: 2, name: "cholera", display: "Cholera" }

  beforeEach(() => {
    actions = [
      { id: 1, disease_id: null },
      { id: 2, disease_id: null },
      { id: 3, disease_id: 1 },
      { id: 4, disease_id: 1 },
      { id: 5, disease_id: 2 },
      { id: 6, disease_id: 2 },
      { id: 7, disease_id: 2 },
    ]
  })

  describe("when the disease is showing", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(true)
      act(() => {
        ReactDOM.render(
          <FilteredDiseaseActions actions={actions} disease={disease} />,
          container
        )
      })
    })

    it("displays the number of Action components that are disease actions", () => {
      const foundActionComponents = container.querySelectorAll("mock-Action")
      expect(foundActionComponents.length).toEqual(3)
    })
  })

  describe("when the disease is not showing", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(false)
      act(() => {
        ReactDOM.render(
          <FilteredDiseaseActions actions={actions} disease={disease} />,
          container
        )
      })
    })

    it("displays no action components", () => {
      const foundActionComponents = container.querySelectorAll("mock-Action")
      expect(foundActionComponents.length).toEqual(0)
    })
  })
})
