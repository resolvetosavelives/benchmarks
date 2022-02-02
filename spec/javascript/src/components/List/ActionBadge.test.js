import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import ActionBadge from "components/List/ActionBadge"

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
      text: "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
      level: 5,
      disease_id: null,
    }
  })

  it("the badge displays the level with the correct color", () => {
    act(() => {
      ReactDOM.render(<ActionBadge action={action} />, container)
    })

    expect(container.innerHTML).toMatch(action.level.toString())
    expect(container.innerHTML).toMatch("color-value-5")
  })
})
