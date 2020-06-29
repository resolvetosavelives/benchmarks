import { describe, expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { useSelector } from "react-redux"
import { act } from "react-dom/test-utils"
import NudgeByTechnicalArea from "components/ChartCard/NudgeByTechnicalArea"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/ChartCard/NudgeByTechnicalAreaOneYear", () => () => (
  <mock-NudgeByTechnicalAreaOneYear />
))
jest.mock("components/ChartCard/NudgeByTechnicalAreaFiveYear", () => () => (
  <mock-NudgeByTechnicalAreaFiveYear />
))

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("renders its content", () => {
  useSelector.mockReturnValue({ term: 100 })

  act(() => {
    ReactDOM.render(<NudgeByTechnicalArea />, container)
  })

  expect(container.querySelectorAll(".nudge-container").length).toEqual(1)
  expect(container.querySelectorAll(".card").length).toEqual(1)
  expect(container.querySelectorAll("svg").length).toEqual(1)
  expect(container.textContent).toContain("Tips for your draft plan")
})

describe("when plan term is 5-year", () => {
  it("renders a NudgeByTechnicalAreaFiveYear", () => {
    useSelector.mockReturnValue({ term: 500 })

    act(() => {
      ReactDOM.render(<NudgeByTechnicalArea />, container)
    })

    expect(
      container.querySelectorAll("mock-NudgeByTechnicalAreaFiveYear").length
    ).toEqual(1)
  })
})

describe("when plan term is 1-year", () => {
  it("renders a NudgeByTechnicalAreaOneYear", () => {
    useSelector.mockReturnValue({ term: 100 })

    act(() => {
      ReactDOM.render(<NudgeByTechnicalArea />, container)
    })

    expect(
      container.querySelectorAll("mock-NudgeByTechnicalAreaOneYear").length
    ).toEqual(1)
  })
})
