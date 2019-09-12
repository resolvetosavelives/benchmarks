import { Application, Controller } from "stimulus"
import CheckboxListController from "checkbox_list_controller"
import $ from "jquery"
jest.mock("jquery")
$.mockImplementation(() => ({
  autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() })
}))

describe("CheckboxListController", () => {
  let selectAllButton, item1Button, item2Button, item3Button
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="checkbox-list">
        <ul>
        <li>
          <input id="select-all"
            type="checkbox"
            data-action="click->checkbox-list#selectAll"
            data-target="checkbox-list.selectAllState" />
          <label for="select-all">Select All</label>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-1"
            value="item-1"
            data-action="click->checkbox-list#selectListItem"
            data-target="checkbox-list.listItem" />
          <label for="item-1">Item 1</label>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-2"
            data-action="click->checkbox-list#selectListItem"
            data-target="checkbox-list.listItem" />
            value="item-2" />
          <label for="item-2">Item 2</label>
        </li>
        <li>
          <input type="checkbox"
            name="selection"
            id="item-3"
            data-action="click->checkbox-list#selectListItem"
            data-target="checkbox-list.listItem" />
            value="item-3" />
          <label for="item-3">Item 3</label>
        </li>
        </ul>
      </div>
    `

    selectAllButton = document.getElementById("select-all")
    item1Button = document.getElementById("item-1")
    item2Button = document.getElementById("item-2")
    item3Button = document.getElementById("item-3")

    const application = Application.start()
    application.register("checkbox-list", CheckboxListController)
  })

  describe("select all", () => {
    it("selects and deselects everything", () => {
      expect(selectAllButton.textContent).toEqual("⏹")

      selectAllButton.click()
      expect(selectAllButton.textContent).toEqual("☑️")
      expect(item1Button.checked).toBe(true)
      expect(item2Button.checked).toBe(true)
      expect(item3Button.checked).toBe(true)

      selectAllButton.click()
      expect(selectAllButton.textContent).toEqual("⏹")
      expect(item1Button.checked).toBe(false)
      expect(item2Button.checked).toBe(false)
      expect(item3Button.checked).toBe(false)
    })

    it("responds to a change in the selections", () => {
      expect(selectAllButton.textContent).toEqual("⏹")
      item1Button.click()
      expect(selectAllButton.textContent).toEqual("—")
    })

    it("deselects everything when clicked while in the some items selected state", () => {
      expect(selectAllButton.textContent).toEqual("⏹")
      item1Button.click()
      selectAllButton.click()
      expect(selectAllButton.textContent).toEqual("⏹")
      expect(item1Button.checked).toBe(false)
    })
  })
})
