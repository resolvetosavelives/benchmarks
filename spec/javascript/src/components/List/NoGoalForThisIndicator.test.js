import { expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import NoGoalForThisIndicator from "components/List/NoGoalForThisIndicator"

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("renders successfully", () => {
  act(() => {
    ReactDOM.render(<NoGoalForThisIndicator />, container)
  })
  expect(container.textContent).toContain("no capacity gap")
  expect(container.querySelectorAll(".row").length).toEqual(1)
  expect(container.querySelectorAll(".col").length).toEqual(1)
})
