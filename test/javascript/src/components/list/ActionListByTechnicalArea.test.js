import React from "react"
import ReactDOM from "react-dom"
import { useSelector } from "react-redux"
import { act } from "react-dom/test-utils"
import ActionListByTechnicalArea from "components/list/ActionListByTechnicalArea"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))
jest.mock("components/list/TechnicalArea", () => () => <mock-technicalarea />)

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("without a technical area selected", () => {
  it("shows all TechnicalArea children", () => {
    useSelector.mockReturnValueOnce([
      {
        id: 1,
        text: "National Legislation, Policy and Financing",
        sequence: 1,
      },
      {
        id: 2,
        text: "IHR Coordination, Communication and Advocacy and Reporting",
        sequence: 2,
      },
    ])
    useSelector.mockReturnValueOnce(null)

    act(() => {
      ReactDOM.render(<ActionListByTechnicalArea />, container)
    })
    const mockTechnicalarea = container.querySelectorAll("mock-technicalarea")
    expect(mockTechnicalarea.length).toEqual(2)
  })
})

describe("with a technical area selected", () => {
  it("shows only one selected TechnicalArea child", () => {
    useSelector.mockReturnValueOnce([
      {
        id: 1,
        text: "National Legislation, Policy and Financing",
        sequence: 1,
      },
      {
        id: 2,
        text: "IHR Coordination, Communication and Advocacy and Reporting",
        sequence: 2,
      },
    ])
    useSelector.mockReturnValueOnce(2)

    act(() => {
      ReactDOM.render(<ActionListByTechnicalArea />, container)
    })
    const mockTechnicalarea = container.querySelectorAll("mock-technicalarea")
    expect(mockTechnicalarea.length).toEqual(1)
  })
})
