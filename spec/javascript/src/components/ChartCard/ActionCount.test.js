import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import ActionCount from "components/ChartCard/ActionCount"

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
  useSelector: jest.fn(),
}))

describe("when count of actions is 3", () => {
  beforeEach(() => useSelector.mockReturnValue(3))

  it("renders with the expected integer", () => {
    act(() => {
      ReactDOM.render(<ActionCount />, container)
    })
    const count = container.querySelector("div.count")

    expect(count.textContent).toEqual("3")
  })
})
