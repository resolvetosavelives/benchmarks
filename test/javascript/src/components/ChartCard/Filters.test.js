import { describe } from "@jest/globals"
import React from "react"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"
import Filters from "components/ChartCard/Filters"
import { useSelector } from "react-redux"

let container

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/ChartCard/ClearFilters", () => () => (
  <mock-ClearFilters />
))
jest.mock("components/ChartCard/FilterTechnicalArea", () => () => (
  <mock-FilterTechnicalArea />
))
jest.mock("components/ChartCard/FilterActionType", () => () => (
  <mock-FilterActionType />
))

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("filters", () => {
  describe("with the bar chart by technical area selected", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(0)
    })

    it("renders the ClearFilters and FilterByTechnicalArea components", () => {
      act(() => {
        ReactDOM.render(<Filters />, container)
      })
      const foundClearFilters = container.querySelectorAll("mock-ClearFilters")
      const foundFilterTechnicalArea = container.querySelectorAll(
        "mock-FilterTechnicalArea"
      )
      const foundFilterActionType = container.querySelectorAll(
        "mock-FilterActionType"
      )

      expect(foundClearFilters.length).toEqual(1)
      expect(foundFilterTechnicalArea.length).toEqual(1)
      expect(foundFilterActionType.length).toEqual(0)
    })
  })

  describe("with the bar chart by action type selected", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(1)
    })

    it("renders the checkbox as unchecked", () => {
      act(() => {
        ReactDOM.render(<Filters />, container)
      })
      const foundClearFilters = container.querySelectorAll("mock-ClearFilters")
      const foundFilterTechnicalArea = container.querySelectorAll(
        "mock-FilterTechnicalArea"
      )
      const foundFilterActionType = container.querySelectorAll(
        "mock-FilterActionType"
      )

      expect(foundClearFilters.length).toEqual(1)
      expect(foundFilterTechnicalArea.length).toEqual(0)
      expect(foundFilterActionType.length).toEqual(1)
    })
  })
})
