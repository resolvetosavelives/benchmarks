import { describe } from "@jest/globals"
import React from "react"
import { act } from "react-dom/test-utils"
import ReactDOM from "react-dom"
import InfluenzaToggle from "components/InfluenzaToggle"
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

    it("renders a button", () => {
      act(() => {
        ReactDOM.render(<InfluenzaToggle />, container)
      })
      const button = container.querySelectorAll("button")

      expect(button.length).toEqual(1)
      expect(button[0].innerHTML).toMatch(" with-checkmark ")
    })
  })

  describe("and with influenza currently hidden", () => {
    beforeEach(() => {
      useSelector.mockReturnValueOnce(false)
    })

    it("renders a button", () => {
      act(() => {
        ReactDOM.render(<InfluenzaToggle />, container)
      })
      const button = container.querySelectorAll("button")

      expect(button.length).toEqual(1)
      expect(button[0].innerHTML).toMatch(" with-circle ")
    })
  })
})
