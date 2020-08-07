import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import ActionBadgePill from "components/List/ActionBadgePill"
import { useSelector } from "react-redux"

jest.mock("config/selectors", () => ({
  makeGetDisplayForDiseaseId: jest.fn(),
}))

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

let container, action

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
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
    useSelector
      .mockReturnValueOnce({
        id: 1,
        disease_ids: [],
      })
      .mockReturnValueOnce(undefined)

    act(() => {
      ReactDOM.render(<ActionBadgePill action={action} />, container)
    })
  })

  it("it displays nothing", () => {
    expect(container.innerHTML).toEqual("")
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
    useSelector
      .mockReturnValueOnce({
        id: 1,
        disease_ids: [1],
      })
      .mockReturnValueOnce("mock-disease-display")

    act(() => {
      ReactDOM.render(<ActionBadgePill action={action} />, container)
    })
  })

  it("it displays the badge pill", () => {
    expect(container.innerHTML).toMatch("mock-disease-display")
  })
})
