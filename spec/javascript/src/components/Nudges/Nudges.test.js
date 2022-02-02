import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import Nudges from "components/Nudges/Nudges"

let container

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/Nudges/NudgeByTechnicalArea", () => () => (
  <mock-nudgebytechnicalarea />
))
jest.mock("components/Nudges/NudgeByActionType", () => () => (
  <mock-nudgebyactiontype />
))

describe("when selected chart tab is zero", () => {
  beforeEach(() => {
    useSelector.mockReturnValue(0)
    act(() => {
      ReactDOM.render(<Nudges />, container)
    })
  })

  it("renders the NudgeByTechnicalArea component", () => {
    const childYes = container.querySelectorAll("mock-nudgebytechnicalarea")
    const childNo = container.querySelectorAll("mock-nudgebyactiontype")

    expect(childYes.length).toEqual(1)
    expect(childNo.length).toEqual(0)
  })
})

describe("when selected chart tab is one", () => {
  beforeEach(() => {
    useSelector.mockReturnValue(1)
    act(() => {
      ReactDOM.render(<Nudges />, container)
    })
  })

  it("renders the NudgeByActionType component", () => {
    const childYes = container.querySelectorAll("mock-nudgebyactiontype")
    const childNo = container.querySelectorAll("mock-nudgebytechnicalarea")

    expect(childYes.length).toEqual(1)
    expect(childNo.length).toEqual(0)
  })
})
