import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import AddAction from "components/List/AddAction"

let container, indicator

jest.mock("react-redux", () => ({
  useDispatch: () => jest.fn(),
  useSelector: jest
    .fn()
    .mockReturnValueOnce([
      {
        id: 17,
        benchmark_indicator_id: 1,
        benchmark_technical_area_id: 1,
        sequence: 1,
        text:
          "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
        level: 4,
      },
      {
        id: 18,
        benchmark_indicator_id: 1,
        benchmark_technical_area_id: 1,
        sequence: 2,
        text:
          "1.1 Assess current relevant legislation, laws, regulations, policy and administrative requirements for IHR implementation and identify gaps, including reporting, prevention and control.",
        level: 5,
      },
    ])
    .mockReturnValue({ 1: [2, 3] }),
}))

jest.mock("react-select", () => () => <mock-select />)

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
  indicator = {
    id: 1,
    benchmark_technical_area_id: 1,
    sequence: 1,
    display_abbreviation: "1.1",
    objective:
      "To assess, adjust and align domestic legislation, laws, regulations, policy and administrative requirements in all relevant sectors t…",
    text:
      "Domestic legislation, laws, regulations, policy an…rs and effectively enable compliance with the IHR",
  }
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("AddAction renders a Select control", () => {
  act(() => {
    ReactDOM.render(<AddAction indicator={indicator} />, container)
  })

  expect(container.innerHTML).toContain("mock-select")
})
