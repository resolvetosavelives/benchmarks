import fs from "fs"
import React from "react"
import { render as renderForConnect } from "../../../test-utils-for-react"
import BarChartByTechnicalArea from "components/ChartCard/BarChartByTechnicalArea"

jest.mock("components/ChartCard/BarChartLegend", () => () => (
  <mock-BarChartLegend />
))

// this taken from Nigeria JEE 1.0 1-yr + Influenza
const stateFromServerForInfluenza = fs.readFileSync(
  `${__dirname}/../../../../fixtures/files/state_from_server_with_influenza.json`,
  "utf-8"
)

it("BarChartByTechnicalArea has the expected 2 divs", () => {
  const initialState = JSON.parse(stateFromServerForInfluenza)
  initialState.dispatch = () => {}
  const renderedComponent = renderForConnect(
    <BarChartByTechnicalArea width="700" height="240" />,
    {
      initialState: initialState,
    }
  )
  const container = renderedComponent.container
  const elComponentContainer = container.querySelectorAll(
    ".chart-container.ct-chart-bar"
  )
  const elChartContainer = container.querySelectorAll(".ct-chart") // react-chartist generates this one

  expect(elComponentContainer.length).toEqual(1)
  expect(elChartContainer.length).toEqual(1)
})
