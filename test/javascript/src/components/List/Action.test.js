import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import $ from "jquery"
import Action from "components/List/Action"
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

let container, action, indicator

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
    useSelector.mockReturnValue({ 13: indicator })
  })

  it("Action has the expected badge, level, ordinal, title, and pill", () => {
    act(() => {
      ReactDOM.render(
        <Action action={action} key={`action-${action.id}`} />,
        container
      )
    })

    expect(container.innerHTML).toMatch(action.text)
    expect(container.innerHTML).toMatch(indicator.display_abbreviation)
    expect(container.innerHTML).toMatch("mock-actionbadge")
  })

  it("calls deleteAnAction when the delete button is clicked", () => {
    const mockDispatch = jest.fn()
    useDispatch.mockReturnValue(mockDispatch)

    act(() => {
      ReactDOM.render(
        <Action action={action} key={`action-${action.id}`} />,
        container
      )
    })
    $(".delete.close", container).trigger("click")
    $(".btn-remove", container).trigger("click")

    expect(mockDispatch).toHaveBeenCalledTimes(1)
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
    useSelector.mockReturnValueOnce({ 13: indicator })
  })

  it("Action has the expected disease badge, ordinal, title and pill", () => {
    act(() => {
      ReactDOM.render(
        <Action action={action} key={`action-${action.id}`} />,
        container
      )
    })

    expect(container.innerHTML).toMatch(action.text)
    expect(container.innerHTML).toMatch(indicator.display_abbreviation)
    expect(container.innerHTML).toMatch("mock-actionbadgepill")
  })
})
