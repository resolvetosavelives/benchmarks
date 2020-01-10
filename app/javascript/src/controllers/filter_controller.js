import { Controller } from "stimulus"
import "bootstrap-multiselect"

export default class extends Controller {
  static targets = ["multiselectTechnicalAreas"]

  connect() {
    if (
      $(this.multiselectTechnicalAreasTarget)
        .siblings()
        .find(".multiselect").length === 0
    ) {
      $(this.multiselectTechnicalAreasTarget).multiselect({
        buttonWidth: "100%",
        maxHeight: 200,
        inheritClass: true,
        onChange: this.filterByTechnicalAreas.bind(this),
        nonSelectedText: this.data.get("placeholder")
      })
    }
    this.allTechnicalAreaOptions = JSON.parse(this.multiselectTechnicalAreasTarget.getAttribute("data-options"))
  }

  technicalAreaRows(id) {
    return Array.from(
      document.getElementsByClassName(`${this.data.get("class-prefix")}-${id}`)
    )
  }

  filterByTechnicalAreas() {
    const selectedTechnicalAreaIds = $(this.multiselectTechnicalAreasTarget).val().map(val => Number(val))

    if (selectedTechnicalAreaIds.length > 0) {
      this.allTechnicalAreaOptions.forEach((technicalArea) => {
        if (selectedTechnicalAreaIds.includes(technicalArea.id)) {
          this.technicalAreaRows(technicalArea.id).forEach(r => {
            r.hidden = false
          })
        } else {
          this.technicalAreaRows(technicalArea.id).forEach(r => {
            r.hidden = true
          })
        }
      })
    } else {
      this.allTechnicalAreaOptions.forEach((technicalArea) => {
        this.technicalAreaRows(technicalArea.id).forEach(r => {
          r.hidden = false
        })
      })
    }
  }
}
