import React from "react"
import { render as renderForConnect } from "../../../test-utils-for-react"
import BarChartByActionType from "components/ChartCard/BarChartByActionType"
import {
  countActionsByActionType,
  getAllActions,
  getMatrixOfActionCountsByActionTypeAndDisease,
  getPlanActionIds,
  getPlanChartLabels,
  getSelectedActionTypeOrdinal,
  getSelectedChartTabIndex,
  getUi,
} from "config/selectors"
import "bootstrap"

jest.mock("config/selectors", () => ({
  countActionsByActionType: jest.fn(),
  getAllActions: jest.fn(),
  getMatrixOfActionCountsByActionTypeAndDisease: jest.fn(),
  getPlanActionIds: jest.fn(),
  getPlanChartLabels: jest.fn(),
  getSelectedActionTypeOrdinal: jest.fn(),
  getSelectedChartTabIndex: jest.fn(),
  getUi: jest.fn(),
}))

it("BarChartByActionType has the expected 2 divs", () => {
  countActionsByActionType.mockReturnValueOnce([2, 3, 5])
  getAllActions.mockReturnValueOnce([{ id: 1 }, { id: 2 }, { id: 3 }])
  getPlanActionIds.mockReturnValueOnce([1, 2])
  getMatrixOfActionCountsByActionTypeAndDisease.mockReturnValueOnce([
    [2, 3, 5],
    [0, 0, 0],
  ])
  getPlanChartLabels.mockReturnValueOnce([["label1", "label2", "label3"], []])
  getSelectedActionTypeOrdinal.mockReturnValueOnce(null)
  getSelectedChartTabIndex.mockReturnValueOnce(1)
  getUi.mockReturnValueOnce({
    isCholeraShowing: true,
    isInfluenzaShowing: true,
  })

  const renderedComponent = renderForConnect(
    <BarChartByActionType width="100%" height="240" />
  )
  const container = renderedComponent.container
  const elComponentContainer = container.querySelectorAll(
    ".chart-container.ct-chart-bar"
  )
  const elChartContainer = container.querySelectorAll(".ct-chart") // react-chartist generates this one

  expect(elComponentContainer.length).toEqual(1)
  expect(elChartContainer.length).toEqual(1)
})
