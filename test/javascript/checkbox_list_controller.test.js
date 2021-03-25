import { Application } from "stimulus"
import CheckboxListController from "checkbox_list_controller"
import $ from "jquery"
jest.mock("jquery")
$.mockImplementation(() => ({
  autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() }),
}))

describe("CheckboxListController", () => {
  let selectAllButton,
    deselectAllButton,
    item1Button,
    item2Button,
    item3Button,
    submitButton
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="checkbox-list">
        <ul>
        <li>
          <a id="select-all" data-action="click->checkbox-list#selectAll" class="text-primary">Select All</a>
          | <a id="deselect-all" data-action="click->checkbox-list#deselectAll" class="text-primary">Deselect All</a>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-1"
            value="item-1"
            data-action="click->checkbox-list#updateState"
            data-checkbox-list-target="listItem" />
          <label for="item-1">Item 1</label>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-2"
            data-action="click->checkbox-list#updateState"
            data-checkbox-list-target="listItem" />
            value="item-2" />
          <label for="item-2">Item 2</label>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-3"
            data-action="click->checkbox-list#updateState"
            data-checkbox-list-target="listItem" />
            value="item-3" />
          <label for="item-3">Item 3</label>
        </li>
        <input type="button" id="submit"
          data-checkbox-list-target="submitForm" />
        </ul>
      </div>
    `

    selectAllButton = document.getElementById("select-all")
    deselectAllButton = document.getElementById("deselect-all")
    item1Button = document.getElementById("item-1")
    item2Button = document.getElementById("item-2")
    item3Button = document.getElementById("item-3")
    submitButton = document.getElementById("submit")

    const application = Application.start()
    application.register("checkbox-list", CheckboxListController)
  })

  describe("select all", () => {
    it("selects and deselects everything", () => {
      selectAllButton.click()
      expect(item1Button.checked).toBe(true)
      expect(item2Button.checked).toBe(true)
      expect(item3Button.checked).toBe(true)
      expect(submitButton.disabled).toBe(false)

      deselectAllButton.click()
      expect(item1Button.checked).toBe(false)
      expect(item2Button.checked).toBe(false)
      expect(item3Button.checked).toBe(false)
      expect(submitButton.disabled).toBe(true)
    })

    it("enables the submit button when anything has been selected", () => {
      expect(submitButton.disabled).toBe(true)
      item1Button.click()
      expect(submitButton.disabled).toBe(false)
    })
  })
})
