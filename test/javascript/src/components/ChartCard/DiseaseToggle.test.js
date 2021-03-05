import { describe } from "@jest/globals"
import React from "react"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"
import DiseaseToggle from "components/ChartCard/DiseaseToggle"
import { useSelector, useDispatch } from "react-redux"

let container

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
  useDispatch: jest.fn(),
}))

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("toggle with a disease", () => {
  const disease = { id: 1, name: "influenza", display: "Influenza" }

  beforeEach(() => {
    useDispatch.mockReturnValueOnce(jest.fn())
  })

  describe("with the disease displayed", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(true)
    })

    it("renders the checkbox as checked", () => {
      act(() => {
        ReactDOM.render(<DiseaseToggle disease={disease} />, container)
      })
      const checkbox = container.querySelectorAll("input[type=checkbox]")

      expect(checkbox.length).toEqual(1)
      expect(checkbox[0].checked).toEqual(true)
    })
  })

  describe("with the disease hidden", () => {
    beforeEach(() => {
      useSelector.mockReturnValue(false)
    })

    it("renders the checkbox as unchecked", () => {
      act(() => {
        ReactDOM.render(<DiseaseToggle disease={disease} />, container)
      })
      const checkbox = container.querySelectorAll("input[type=checkbox]")

      expect(checkbox.length).toEqual(1)
      expect(checkbox[0].checked).toEqual(false)
    })
  })
})
