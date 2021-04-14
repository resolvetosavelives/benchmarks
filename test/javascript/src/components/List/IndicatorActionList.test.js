import { afterEach, beforeEach, describe, expect, it } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import IndicatorActionList from "components/List/IndicatorActionList"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/List/AddAction", () => () => <mock-AddAction />)
jest.mock("components/List/NoGoalForThisIndicator", () => () => (
  <mock-NoGoalForThisIndicator />
))
jest.mock("components/List/FilteredGeneralActions", () => () => (
  <mock-FilteredGeneralActions />
))
jest.mock("components/List/FilteredDiseaseActions", () => () => (
  <mock-FilteredDiseaseActions />
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
    const mockPlanGoalMap = { 17: { id: 2, value: 3 } }
    const mockActions = [
      {
        id: 2,
        benchmark_technical_area_id: 1,
        benchmark_indicator_id: 1,
        disease_id: 1,
      },
      {
        id: 5,
        benchmark_technical_area_id: 1,
        benchmark_indicator_id: 1,
        disease_id: null,
      },
    ]

    describe("and the plan has diseases", () => {
      beforeEach(() => {
        const mockPlanDiseases = [
          { id: 1, name: "influenza", display: "Influenza" },
          { id: 2, name: "cholera", display: "Cholera" },
        ]
        useSelector
          .mockReturnValueOnce(mockPlanGoalMap)
          .mockReturnValueOnce(mockPlanDiseases)
          .mockReturnValueOnce(mockActions)
      })

      fit("renders a General Action component, 2 Disease Action components, and an Add Action components and 1 child AddAction component", () => {
        act(() => {
          ReactDOM.render(
            <IndicatorActionList indicator={{ id: 17 }} />,
            container
          )
        })
        const foundGeneralActionsComponents = container.querySelectorAll(
          "mock-FilteredGeneralActions"
        )
        const foundDiseaseActionsComponents = container.querySelectorAll(
          "mock-FilteredDiseaseActions"
        )
        const foundAddActionComponents = container.querySelectorAll(
          "mock-AddAction"
        )
        const foundNoGoalComponent = container.querySelectorAll(
          "mock-NoGoalForThisIndicator"
        )
        expect(foundGeneralActionsComponents.length).toEqual(1)
        expect(foundDiseaseActionsComponents.length).toEqual(2)
        expect(foundAddActionComponents.length).toEqual(1)
        expect(foundNoGoalComponent.length).toEqual(0)
      })
    })

    describe("and the plan has no diseases", () => {
      beforeEach(() => {
        const mockPlanDiseases = []
        useSelector
          .mockReturnValueOnce(mockPlanGoalMap)
          .mockReturnValueOnce(mockPlanDiseases)
      })

      it("renders a General Action component, no Disease Action components, and an Add Action components and 1 child AddAction component", () => {
        act(() => {
          ReactDOM.render(
            <IndicatorActionList indicator={{ id: 17 }} />,
            container
          )
        })

        const foundGeneralActionsComponents = container.querySelectorAll(
          "mock-FilteredGeneralActions"
        )
        const foundDiseaseActionsComponents = container.querySelectorAll(
          "mock-FilteredDiseaseActions"
        )
        const foundAddActionComponents = container.querySelectorAll(
          "mock-AddAction"
        )
        const foundNoGoalComponent = container.querySelectorAll(
          "mock-NoGoalForThisIndicator"
        )
        expect(foundGeneralActionsComponents.length).toEqual(1)
        expect(foundDiseaseActionsComponents.length).toEqual(0)
        expect(foundAddActionComponents.length).toEqual(1)
        expect(foundNoGoalComponent.length).toEqual(0)
      })
    })
  })

  describe("and there are zero actions", () => {
    beforeEach(() => {
      let mockPlanGoalMap = { 17: { id: 2, value: null } }
      let mockActions = []
      const mockPlanDiseases = []
      useSelector
        .mockReturnValueOnce(mockPlanGoalMap)
        .mockReturnValueOnce(mockPlanDiseases)
        .mockReturnValueOnce(mockActions)
    })

    it("renders a General Action component, no Disease Action Components, and 1 child AddAction component", () => {
      act(() => {
        ReactDOM.render(
          <IndicatorActionList indicator={{ id: 17 }} />,
          container
        )

        const foundGeneralActionsComponents = container.querySelectorAll(
          "mock-FilteredGeneralActions"
        )
        const foundDiseaseActionsComponents = container.querySelectorAll(
          "mock-FilteredDiseaseActions"
        )
        const foundAddActionComponents = container.querySelectorAll(
          "mock-AddAction"
        )
        const foundNoGoalComponent = container.querySelectorAll(
          "mock-NoGoalForThisIndicator"
        )
        expect(foundGeneralActionsComponents.length).toEqual(1)
        expect(foundDiseaseActionsComponents.length).toEqual(0)
        expect(foundAddActionComponents.length).toEqual(1)
        expect(foundNoGoalComponent.length).toEqual(1)
      })
    })
  })
})

describe("when there is no goal", () => {
  beforeEach(() => {
    const mockPlanGoalMap = { 17: { id: 2, value: null } }
    const mockPlanDiseases = [
      { id: 1, name: "influenza", display: "Influenza" },
      { id: 2, name: "cholera", display: "Cholera" },
    ]
    const mockActions = [
      {
        id: 2,
        benchmark_technical_area_id: 1,
        benchmark_indicator_id: 1,
        disease_id: 1,
      },
      {
        id: 5,
        benchmark_technical_area_id: 1,
        benchmark_indicator_id: 1,
        disease_id: null,
      },
    ]
    useSelector
      .mockReturnValueOnce(mockPlanGoalMap)
      .mockReturnValueOnce(mockPlanDiseases)
      .mockReturnValueOnce(mockActions)
  })

  it("renders NoGoalForThisIndicator, any Actions, and Add Action", () => {
    act(() => {
      ReactDOM.render(<IndicatorActionList indicator={{ id: 17 }} />, container)
    })
    const foundGeneralActionsComponents = container.querySelectorAll(
      "mock-FilteredGeneralActions"
    )
    const foundDiseaseActionsComponents = container.querySelectorAll(
      "mock-FilteredDiseaseActions"
    )
    const foundAddActionComponents = container.querySelectorAll(
      "mock-AddAction"
    )
    const foundNoGoalComponent = container.querySelectorAll(
      "mock-NoGoalForThisIndicator"
    )
    expect(foundGeneralActionsComponents.length).toEqual(1)
    expect(foundDiseaseActionsComponents.length).toEqual(2)
    expect(foundAddActionComponents.length).toEqual(1)
    expect(foundAddActionComponents.length).toEqual(1)
    expect(foundNoGoalComponent.length).toEqual(1)
  })
})
