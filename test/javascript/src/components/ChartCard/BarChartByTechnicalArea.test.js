import React from "react"
import { render as renderForConnect } from "../../../test-utils-for-react"
import BarChartByTechnicalArea from "components/ChartCard/BarChartByTechnicalArea"
import {
  countActionsByTechnicalArea,
  getAllActions,
  getAllTechnicalAreas,
  getMatrixOfActionCountsByTechnicalAreaAndDisease,
  getPlanChartLabels,
  getSelectedTechnicalAreaId,
  getSelectedChartTabIndex,
} from "config/selectors"

jest.mock("config/selectors", () => ({
  countActionsByTechnicalArea: jest.fn(),
  getAllActions: jest.fn(),
  getAllTechnicalAreas: jest.fn(),
  getMatrixOfActionCountsByTechnicalAreaAndDisease: jest.fn(),
  getPlanChartLabels: jest.fn(),
  getSelectedTechnicalAreaId: jest.fn(),
  getSelectedChartTabIndex: jest.fn(),
}))

it("BarChartByTechnicalArea has the expected 2 divs", () => {
  countActionsByTechnicalArea.mockReturnValueOnce([2, 3, 5])
  getAllActions.mockReturnValueOnce([{ id: 1 }, { id: 2 }, { id: 3 }])
  getAllTechnicalAreas.mockReturnValueOnce([{ id: 4 }, { id: 5 }, { id: 6 }])
  getMatrixOfActionCountsByTechnicalAreaAndDisease.mockReturnValueOnce([
    [2, 3, 5],
    [0, 0, 0],
  ])
  getPlanChartLabels.mockReturnValueOnce([["label1", "label2", "label3"], []])
  getSelectedTechnicalAreaId.mockReturnValueOnce(null)
  getSelectedChartTabIndex.mockReturnValueOnce(0)
  const renderedComponent = renderForConnect(
    <BarChartByTechnicalArea width="100%" height="240" />
  )
  const container = renderedComponent.container
  const elComponentContainer = container.querySelectorAll(
    ".chart-container.ct-chart-bar"
  )
  const elChartContainer = container.querySelectorAll(".ct-chart") // react-chartist generates this one

  expect(elComponentContainer.length).toEqual(1)
  expect(elChartContainer.length).toEqual(1)
})
