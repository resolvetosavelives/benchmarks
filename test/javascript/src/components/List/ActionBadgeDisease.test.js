import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import ActionBadgeDisease from "components/List/ActionBadgeDisease"
import { getColorForDiseaseId } from "config/helpers"
// import { makeGetDisplayForDiseaseId } from "config/selectors"

jest.mock("config/helpers", () => ({
  getColorForDiseaseId: jest.fn(),
}))

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

describe("with an action that is disease specific", () => {
  beforeEach(() => {
    getColorForDiseaseId.mockReturnValueOnce(() => "mock-disease-color")
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
      ReactDOM.render(<ActionBadgeDisease action={action} />, container)
    })
  })

  it("the badge displays the badge with the correct color", () => {
    expect(container.innerHTML).toMatch("mock-disease-color")
  })
})
