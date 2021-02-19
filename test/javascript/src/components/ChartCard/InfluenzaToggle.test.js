import { describe } from "@jest/globals"
import React from "react"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"
import InfluenzaToggle from "components/ChartCard/InfluenzaToggle"
import { useSelector, useDispatch } from "react-redux"

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
  useSelector: jest.fn(),
  useDispatch: jest.fn(),
}))

describe("plan without influenza", () => {
  beforeEach(() => {
    useSelector.mockReturnValueOnce(false).mockReturnValueOnce(true)
    useDispatch.mockReturnValueOnce(jest.fn())
  })

  it("renders nothing", () => {
    act(() => {
      ReactDOM.render(<InfluenzaToggle />, container)
    })
    const div = container.querySelectorAll("div")

    expect(div.length).toEqual(0)
  })
})

describe("plan with influenza", () => {
  beforeEach(() => {
    useSelector.mockReturnValueOnce(true)
    useDispatch.mockReturnValueOnce(jest.fn())
  })

  describe("and with influenza currently displayed", () => {
    beforeEach(() => {
      useSelector.mockReturnValueOnce(true)
    })

    it("renders the checkbox as checked", () => {
      act(() => {
        ReactDOM.render(<InfluenzaToggle />, container)
      })
      const checkbox = container.querySelectorAll("input[type=checkbox]")

      expect(checkbox.length).toEqual(1)
      expect(checkbox[0].checked).toEqual(true)
    })
  })

  describe("and with influenza currently hidden", () => {
    beforeEach(() => {
      useSelector.mockReturnValueOnce(false)
    })

    it("renders the checkbox as unchecked", () => {
      act(() => {
        ReactDOM.render(<InfluenzaToggle />, container)
      })
      const checkbox = container.querySelectorAll("input[type=checkbox]")

      expect(checkbox.length).toEqual(1)
      expect(checkbox[0].checked).toEqual(false)
    })
  })
})
