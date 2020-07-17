import { afterEach, beforeEach, describe, expect, it } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import IndicatorActionList from "components/List/IndicatorActionList"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/List/Action", () => () => <mock-action />)
jest.mock("components/List/AddAction", () => () => <mock-add-action />)
jest.mock("components/List/NoGoalForThisIndicator", () => () => (
  <mock-NoGoalForThisIndicator />
))

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
}),
  afterEach(() => {
    document.body.removeChild(container)
    container = null
  })

describe("when a goal is present", () => {
  describe("and there are actions present", () => {
    beforeEach(() => {
      let mockPlanGoalMap = { 17: { id: 1 } }
      let mockPlanActionIdsByIndicator = { 17: [2, 11, 5] }
      let mockAllActions = [
        { id: 2 },
        { id: 5 },
        { id: 13 },
        { id: 11 },
        { i2: 6 },
      ]
      useSelector
        .mockReturnValueOnce(mockPlanGoalMap)
        .mockReturnValueOnce(mockPlanActionIdsByIndicator)
        .mockReturnValueOnce(mockAllActions)
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

      expect(foundActionComponents.length).toEqual(3)
      expect(foundAddActionComponents.length).toEqual(1)
    })
  })

  describe("and there are zero actions", () => {
    beforeEach(() => {
      let mockPlanGoalMap = { 17: { id: 1 } }
      let mockPlanActionIdsByIndicator = []
      let mockAllActions = []
      useSelector
        .mockReturnValueOnce(mockPlanGoalMap)
        .mockReturnValueOnce(mockPlanActionIdsByIndicator)
        .mockReturnValueOnce(mockAllActions)
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
    let mockPlanGoalMap = { 17: null }
    let mockPlanActionIdsByIndicator = []
    let mockAllActions = []
    useSelector
      .mockReturnValueOnce(mockPlanGoalMap)
      .mockReturnValueOnce(mockPlanActionIdsByIndicator)
      .mockReturnValueOnce(mockAllActions)
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
