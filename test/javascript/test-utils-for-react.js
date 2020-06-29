//
// borrowed from: https://redux.js.org/recipes/writing-tests#connected-components
// useful for setup of react/redux components that use the connect() method instead of hooks.
//
import React from "react"
import { render as rtlRender } from "@testing-library/react"
import { Provider } from "react-redux"
import configureStore from "redux-mock-store"

const middlewares = []
const mockStore = configureStore(middlewares)

function render(
  ui,
  { initialState = {}, store = mockStore(initialState), ...renderOptions } = {}
) {
  // eslint-disable-next-line react/prop-types
  function Wrapper({ children }) {
    return <Provider store={store}>{children}</Provider>
  }
  return rtlRender(ui, { wrapper: Wrapper, ...renderOptions })
}

// re-export everything
export * from "@testing-library/react"
// override render method
export { render }
