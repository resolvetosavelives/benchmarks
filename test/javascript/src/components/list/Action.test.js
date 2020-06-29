import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import $ from "jquery"
import Action from "components/list/Action"
import { deleteAnAction } from "config/actions"
import { useSelector, useDispatch } from "react-redux"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
  useDispatch: jest.fn(),
}))
jest.mock("config/actions", () => ({
  deleteAnAction: jest.fn(),
}))

let container, action, indicator, mockUseDispatch

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
  action = {
    id: 17,
    benchmark_indicator_id: 13,
    benchmark_technical_area_id: 1,
    sequence: 1,
    text:
      "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
    level: 5,
  }
  indicator = {
    id: 13,
    benchmark_technical_area_id: 1,
    sequence: 1,
    display_abbreviation: "1.1",
    objective:
      "To assess, adjust and align domestic legislation, laws, regulations, policy and administrative requirements in all relevant sectors t…",
    text:
      "Domestic legislation, laws, regulations, policy an…rs and effectively enable compliance with the IHR",
  }
  useSelector
    .mockImplementationOnce((callback) =>
      callback({
        indicatorMap: { 13: indicator },
      })
    )
    .mockImplementationOnce((callback) =>
      callback({
        actions: { 17: action },
      })
    )
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

it("Action has the expected level, ordinal and title", () => {
  act(() => {
    ReactDOM.render(<Action id={action.id} key={action.id} />, container)
  })

  expect(container.innerHTML).toMatch(action.level.toString())
  expect(container.innerHTML).toMatch(action.text)
  expect(container.innerHTML).toMatch(indicator.display_abbreviation)
})

it("calls deleteAnAction when the delete button is clicked", () => {
  const mockDeleteAnAction = jest.fn()
  mockUseDispatch = jest.fn()
  deleteAnAction.mockReturnValueOnce(mockDeleteAnAction)
  useDispatch.mockReturnValueOnce(mockUseDispatch)

  act(() => {
    ReactDOM.render(<Action id={action.id} key={action.id} />, container)
  })
  $(".delete.close", container).trigger("click")

  expect(mockUseDispatch).toHaveBeenCalledTimes(1)
  expect(mockUseDispatch).toHaveBeenLastCalledWith(mockDeleteAnAction)
})
