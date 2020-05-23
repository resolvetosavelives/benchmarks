import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useDispatch } from "react-redux"
import ActionCount from "components/ActionCount"
import { clearFilterCriteria } from "config/actions"

let container

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

jest.mock("config/actions", () => ({
  clearFilterCriteria: jest.fn(),
}))
jest.mock("react-redux", () => ({
  useDispatch: jest.fn(),
  useSelector: jest
    .fn()
    .mockImplementation((state) => state({ planActionIds: [12, 34, 57] })),
}))

it("ActionCount populates itself with the expected integer", () => {
  act(() => {
    ReactDOM.render(<ActionCount />, container)
  })
  const span = container.querySelector("span")

  expect(span.textContent).toEqual("3")
})

it("click on the ActionCount circle triggers an event", () => {
  const mockClearFilterCriteria = jest.fn()
  const mockUseDispatch = jest.fn()
  clearFilterCriteria.mockReturnValueOnce(mockClearFilterCriteria)
  useDispatch.mockReturnValueOnce(mockUseDispatch)

  act(() => {
    ReactDOM.render(<ActionCount />, container)
  })
  const actionCountCircle = container.getElementsByClassName(
    "action-count-circle"
  )[0]
  actionCountCircle.click()

  expect(mockUseDispatch).toHaveBeenCalledTimes(1)
  expect(mockUseDispatch).toHaveBeenLastCalledWith(mockClearFilterCriteria)
})
