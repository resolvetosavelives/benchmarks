import { expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"
import NudgeByTechnicalAreaOneYear from "components/Nudges/NudgeByTechnicalAreaOneYear"

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
    ReactDOM.render(<NudgeByTechnicalAreaOneYear />, container)
  })

  expect(container.querySelectorAll("ul").length).toEqual(1)
  expect(container.querySelectorAll("li").length).toEqual(2)
})
