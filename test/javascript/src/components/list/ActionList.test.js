import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { useSelector } from "react-redux"
import {
  LIST_MODE_BY_ACTION_TYPE,
  LIST_MODE_BY_TECHNICAL_AREA,
} from "config/constants"
import ActionList from "components/list/ActionList"

jest.mock("components/list/ActionListByActionType", () => () => (
  <mock-actionlistbyactiontype />
))
jest.mock("components/list/ActionListByTechnicalArea", () => () => (
  <mock-actionlistbytechnicalarea />
))
jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
}))

let container
beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("when listMode equals LIST_MODE_BY_ACTION_TYPE it renders an ActionListByActionType", () => {
  useSelector.mockReturnValue(LIST_MODE_BY_ACTION_TYPE)
  act(() => {
    ReactDOM.render(<ActionList />, container)
  })
  const byActionTypeComponent = container.querySelectorAll(
    "mock-actionlistbyactiontype"
  )

  expect(byActionTypeComponent.length).toEqual(1)
})

it("when listMode equals LIST_MODE_BY_ACTION_TYPE it renders an ActionListByActionType", () => {
  useSelector.mockReturnValue(LIST_MODE_BY_TECHNICAL_AREA)
  act(() => {
    ReactDOM.render(<ActionList />, container)
  })
  const byTechnicalAreaComponent = container.querySelectorAll(
    "mock-actionlistbytechnicalarea"
  )

  expect(byTechnicalAreaComponent.length).toEqual(1)
})

it("when listMode is unset it defaults to an ActionListByActionType", () => {
  act(() => {
    ReactDOM.render(<ActionList />, container)
  })
  const byTechnicalAreaComponent = container.querySelectorAll(
    "mock-actionlistbytechnicalarea"
  )

  expect(byTechnicalAreaComponent.length).toEqual(1)
})
