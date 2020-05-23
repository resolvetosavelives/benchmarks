import { describe, expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import IndicatorActionList from "components/list/IndicatorActionList"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/list/Action", () => () => <mock-action />)
jest.mock("components/list/AddAction", () => () => <mock-add-action />)
jest.mock("components/list/NoGoalForThisIndicator", () => () => (
  <mock-NoGoalForThisIndicator />
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

describe("when a goal is present", () => {
  describe("and there are actions present", () => {
    beforeEach(() => {
      useSelector
        .mockImplementationOnce((callback) =>
          callback({
            planGoalMap: { 17: { id: 17 } },
          })
        )
        .mockImplementationOnce((callback) =>
          callback({
            planActionIdsByIndicator: { 17: [2, 5, 7, 11, 13] },
          })
        )
    })

    it("renders 5 child Action components and 1 child AddAction component", () => {
      act(() => {
        ReactDOM.render(
          <IndicatorActionList indicator={{ id: 17 }} />,
          container
        )
      })
      const foundActionComponents = container.querySelectorAll("mock-action")
      const foundAddActionComponents = container.querySelectorAll(
        "mock-add-action"
      )

      expect(foundActionComponents.length).toEqual(5)
      expect(foundAddActionComponents.length).toEqual(1)
    })
  })

  describe("and there are zero actions", () => {
    beforeEach(() => {
      useSelector
        .mockImplementationOnce((callback) =>
          callback({
            planGoalMap: { 17: { id: 17 } },
          })
        )
        .mockImplementationOnce((callback) =>
          callback({
            planActionIdsByIndicator: { 17: [] },
          })
        )
    })

    it("renders zero child Action components but 1 child AddAction component", () => {
      act(() => {
        ReactDOM.render(
          <IndicatorActionList indicator={{ id: 17 }} />,
          container
        )
      })
      const foundActionComponents = container.querySelectorAll("mock-action")
      const foundAddActionComponents = container.querySelectorAll(
        "mock-add-action"
      )

      expect(foundActionComponents.length).toEqual(0)
      expect(foundAddActionComponents.length).toEqual(1)
    })
  })
})

describe("when there is no goal", () => {
  beforeEach(() => {
    useSelector
      .mockImplementationOnce((callback) =>
        callback({
          planGoalMap: {},
        })
      )
      .mockImplementation((callback) =>
        callback({
          planActionIdsByIndicator: {},
        })
      )
  })

  it("does not render any child AddAction components and instead renders a NoGoalForThisIndicator", () => {
    act(() => {
      ReactDOM.render(<IndicatorActionList indicator={{ id: 17 }} />, container)
    })
    const foundActionComponents = container.querySelectorAll("mock-action")
    const foundAddActionComponents = container.querySelectorAll(
      "mock-add-action"
    )
    const foundNoGoalComponent = container.querySelectorAll(
      "mock-NoGoalForThisIndicator"
    )

    expect(foundActionComponents.length).toEqual(0)
    expect(foundAddActionComponents.length).toEqual(0)
    expect(foundNoGoalComponent.length).toEqual(1)
  })
})
