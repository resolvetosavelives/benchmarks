import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import $ from "jquery"
import Action from "components/List/Action"
import { deleteAnAction } from "config/actions"
import { useSelector, useDispatch } from "react-redux"

jest.mock("react-redux", () => ({
  useSelector: jest.fn(),
  useDispatch: jest.fn(),
}))
jest.mock("config/actions", () => ({
  deleteAnAction: jest.fn(),
}))
jest.mock("components/List/ActionBadgePill", () => () => (
  <mock-actionbadgepill />
))
jest.mock("components/List/ActionBadge", () => () => <mock-actionbadge />)
jest.mock("components/List/ActionBadgeDisease", () => () => (
  <mock-actionbadgedisease />
))

let container, action, indicator, mockUseDispatch

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
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
    .mockReturnValueOnce({ 13: indicator })
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

describe("when the action is not disease specific", () => {
  beforeEach(() => {
    action = {
      id: 17,
      benchmark_indicator_id: 13,
      benchmark_technical_area_id: 1,
      sequence: 1,
      text:
        "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
      level: 5,
      disease_id: null,
    }
  })

  it("Action has the expected badge, level, ordinal, title, and pill", () => {
    act(() => {
      ReactDOM.render(<Action id={action.id} key={action.id} />, container)
    })

    expect(container.innerHTML).toMatch(action.text)
    expect(container.innerHTML).toMatch(indicator.display_abbreviation)
    expect(container.innerHTML).toMatch("mock-actionbadge")
    expect(container.innerHTML).toMatch("mock-actionbadgepill")
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
})

describe("when the Action is disease specific", () => {
  beforeEach(() => {
    action = {
      id: 17,
      benchmark_indicator_id: 13,
      benchmark_technical_area_id: 1,
      sequence: 1,
      text:
        "Confirm that relevant legislation, laws, regulatio… of IHR implementation based on the risk profile.",
      level: null,
      disease_id: 1,
    }
  })

  it("Action has the expected disease badge, ordinal, title and pill", () => {
    act(() => {
      ReactDOM.render(<Action id={action.id} key={action.id} />, container)
    })

    expect(container.innerHTML).toMatch(action.text)
    expect(container.innerHTML).toMatch(indicator.display_abbreviation)
    expect(container.innerHTML).toMatch("mock-actionbadgedisease")
    expect(container.innerHTML).toMatch("mock-actionbadgepill")
  })
})
