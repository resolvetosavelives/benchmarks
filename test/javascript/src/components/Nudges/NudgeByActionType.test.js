import fs from "fs"
import { describe, expect, it, beforeEach, afterEach } from "@jest/globals"
import React from "react"
import ReactDOM from "react-dom"
import { useSelector } from "react-redux"
import { act } from "react-dom/test-utils"
import NudgeByActionType from "components/Nudges/NudgeByActionType"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

const strNudgesByActionType = fs.readFileSync(
  `${__dirname}/../../../../../app/fixtures/nudges_for_action_types.json`,
  "utf-8"
)
const dataNudgesByActionType = JSON.parse(strNudgesByActionType)

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("when no ActionType is selected", () => {
  it("renders Nudge content zero", () => {
    useSelector
      .mockReturnValueOnce(dataNudgesByActionType)
      .mockReturnValueOnce(null)
      .mockReturnValueOnce(Array(15).fill(0))

    act(() => {
      ReactDOM.render(<NudgeByActionType />, container)
    })

    expect(container.querySelectorAll(".nudge-content-0").length).toEqual(1)
  })
})

describe("when an ActionType is selected", () => {
  describe("and is two-threshold", () => {
    it("renders the content for the given ActionType", () => {
      const a = Array(15).fill(0)
      a[1] = 40
      useSelector
        .mockReturnValueOnce(dataNudgesByActionType)
        .mockReturnValueOnce(2)
        .mockReturnValueOnce(a)

      act(() => {
        ReactDOM.render(<NudgeByActionType />, container)
      })

      expect(container.querySelector("h4").textContent).toEqual(
        "assessment and data use actions"
      )
      expect(container.querySelectorAll("li").length).toEqual(4)
    })
  })
})

describe("when an ActionType is selected", () => {
  describe("and is one-threshold", () => {
    it("renders the content for the given ActionType", () => {
      const a = Array(15).fill(0)
      const selectedActionTypeOrdinal = 4
      a[selectedActionTypeOrdinal - 1] = 7
      useSelector
        .mockReturnValueOnce(dataNudgesByActionType)
        .mockReturnValueOnce(selectedActionTypeOrdinal)
        .mockReturnValueOnce(a)

      act(() => {
        ReactDOM.render(<NudgeByActionType />, container)
      })

      expect(container.querySelector("h4").textContent).toEqual(
        "designation actions"
      )
      expect(container.querySelectorAll("li").length).toEqual(3)
    })
  })
})
