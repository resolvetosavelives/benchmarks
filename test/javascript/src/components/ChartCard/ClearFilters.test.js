import { describe } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useDispatch } from "react-redux"
import { clearFilterCriteria } from "config/actions"
import ClearFilters from "components/ChartCard/ClearFilters"

jest.mock("react-redux", () => ({
  useDispatch: jest.fn(),
}))
jest.mock("config/actions", () => ({
  clearFilterCriteria: jest.fn(),
}))

describe("ClearFilters component", () => {
  let container, mockClearFilterCriteria, mockUseDispatch
  beforeEach(() => {
    container = document.createElement("div")
    document.body.appendChild(container)
    mockClearFilterCriteria = jest.fn()
    clearFilterCriteria.mockReturnValueOnce(mockClearFilterCriteria)
    mockUseDispatch = jest.fn()
    useDispatch.mockReturnValueOnce(mockUseDispatch)
  })

  afterEach(() => {
    document.body.removeChild(container)
    container = null
  })

  it("handles click on the A tag", () => {
    act(() => {
      ReactDOM.render(<ClearFilters />, container)
    })
    const anchor = container.querySelector("a")
    anchor.click()

    expect(mockUseDispatch).toHaveBeenCalledTimes(1)
    expect(mockUseDispatch).toHaveBeenLastCalledWith(mockClearFilterCriteria)
  })
})
