import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import TechnicalArea from "components/List/TechnicalArea"

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
  useSelector: jest.fn().mockImplementation((callback) =>
    callback({
      indicators: [
        {
          id: 1,
          benchmark_technical_area_id: 1,
          sequence: 1,
          display_abbreviation: "1.1",
          text:
            "Domestic legislation, laws, regulations, policy an…rs and effectively enable compliance with the IHR",
        },
        {
          id: 2,
          benchmark_technical_area_id: 1,
          sequence: 2,
          display_abbreviation: "1.2",
          text:
            "Financing is available for the implementation of IHR capacities",
        },
        {
          id: 3,
          benchmark_technical_area_id: 2,
          sequence: 1,
          display_abbreviation: "2.1",
          text:
            "Financing available for timely response to public health emergencies",
        },
      ],
    })
  ),
}))
jest.mock("components/List/Indicator", () => () => <mock-indicator />)

const technicalArea = { id: 1, sequence: 1, text: "Antimicrobial Resistance" }

it("TechnicalArea has the expected ordinal and title", () => {
  act(() => {
    ReactDOM.render(<TechnicalArea technicalArea={technicalArea} />, container)
  })
  const h3 = container.querySelector("H3")
  expect(h3.textContent).toEqual("1. Antimicrobial Resistance")
})

it("TechnicalArea has child Indicators filtered appropriately", () => {
  act(() => {
    ReactDOM.render(<TechnicalArea technicalArea={technicalArea} />, container)
  })
  const mockIndicator = container.querySelectorAll("mock-indicator")
  expect(mockIndicator.length).toEqual(2)
})
