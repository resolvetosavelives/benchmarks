import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import ActionListByTechnicalArea from "components/list/ActionListByTechnicalArea"

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
  useSelector: jest.fn().mockImplementation((callback) =>
    callback({
      technicalAreas: [
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
      ],
    })
  ),
}))
jest.mock("components/list/TechnicalArea", () => () => <mock-technicalarea />)

it("TechnicalArea has child Indicators filtered appropriately", () => {
  act(() => {
    ReactDOM.render(<ActionListByTechnicalArea />, container)
  })
  const mockTechnicalarea = container.querySelectorAll("mock-technicalarea")
  expect(mockTechnicalarea.length).toEqual(2)
})
