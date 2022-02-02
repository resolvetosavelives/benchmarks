import React from "react"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import FilteredGeneralActions from "components/List/FilteredGeneralActions"

jest.mock("components/List/Action", () => () => <mock-Action />)

let container, actions

beforeEach(() => {
  container = document.createElement("div")
  document.body.appendChild(container)
})

afterEach(() => {
  document.body.removeChild(container)
  container = null
})

describe("with actions", () => {
  beforeEach(() => {
    actions = [
      { id: 1, disease_id: null },
      { id: 2, disease_id: null },
      { id: 3, disease_id: 1 },
      { id: 4, disease_id: 1 },
      { id: 5, disease_id: 2 },
      { id: 6, disease_id: 2 },
      { id: 7, disease_id: 2 },
    ]
  })

  it("displays the number of Action components that are general actions", () => {
    act(() => {
      ReactDOM.render(<FilteredGeneralActions actions={actions} />, container)
    })

    const foundActionComponents = container.querySelectorAll("mock-Action")
    expect(foundActionComponents.length).toEqual(2)
  })
})
