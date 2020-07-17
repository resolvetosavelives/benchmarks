import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import ActionBadgePill from "components/List/ActionBadgePill"
import { getDisplayForDiseaseId } from "config/selectors"

jest.mock("config/selectors", () => ({
  getDisplayForDiseaseId: jest.fn(),
}))

let container, action

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
  getDisplayForDiseaseId.mockReturnValueOnce("mock-disease-display")
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("with an action that is not disease specific", () => {
  beforeEach(() => {
    action = {
      id: 17,
      benchmark_indicator_id: 13,
      benchmark_technical_area_id: 1,
      sequence: 1,
      text:
        "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
      level: 5,
      disease_id: null,
    }

    act(() => {
      ReactDOM.render(<ActionBadgePill action={action} />, container)
    })
  })

  it("it displays nothing", () => {
    expect(container.innerHTML).not.toMatch("mock-disease-display")
  })
})

describe("with an action that is disease specific", () => {
  beforeEach(() => {
    action = {
      id: 17,
      benchmark_indicator_id: 13,
      benchmark_technical_area_id: 1,
      sequence: 1,
      text:
        "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
      level: null,
      disease_id: 1,
    }

    act(() => {
      ReactDOM.render(<ActionBadgePill action={action} />, container)
    })
  })

  it("it displays the badge pill", () => {
    expect(container.innerHTML).toMatch("mock-disease-display")
  })
})
