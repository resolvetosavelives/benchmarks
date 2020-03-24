import { Controller } from "stimulus"
import $ from "jquery"
import Hogan from "hogan.js"

export default class extends Controller {
  static targets = [
    "filterForm",
    "documentCount",
    "technicalAreaSelect",
    "checkboxForReferenceType",
    "filterCriteriaDisplay",
  ]

  initialize() {
    this.resetState()
  }

  resetState() {
    this.currentTechnicalAreaId = null
    this.currentReferenceTypeOrdinals = []
  }

  connect() {
    $(this.technicalAreaSelectTarget).chosen({
      no_results_text: "No countries match",
    })
    $(this.technicalAreaSelectTarget).on(
      "change",
      this.handleSelectTechnicalArea.bind(this)
    )
    this.technicalAreas = JSON.parse(this.data.get("technicalAreas"))
    this.templateSelector = this.data.get("templateSelector")
    this.updateDocumentCountDisplay()
  }

  handleSelectTechnicalArea(jqEvent, selectedValue) {
    const taID = parseInt(selectedValue.selected)
    this.currentTechnicalAreaId = taID
    this.updateFilterCriteria()
  }

  updateDocumentCountDisplay() {
    const newCount = $(".document.row:visible", this.element).length
    const referenceWord = newCount === 1 ? "reference" : "references"
    const countDisplayText = `${newCount} ${referenceWord}`
    $(this.documentCountTarget).html(countDisplayText)
  }

  resetForm(event) {
    event.preventDefault()
    event.stopPropagation()
    this.showAllDocuments()
    this.updateDocumentCountDisplay()
    this.filterFormTarget.reset()
    this.refreshTheChosenMenu()
    this.resetState()
    this.updateFilterCriteria()
  }

  showAllDocuments() {
    $(".document.row", this.element).show()
  }

  handleCheckboxToggle() {
    const selectedReferenceTypes = this.checkboxForReferenceTypeTargets.reduce(
      (accumulator, chk) => {
        if (chk.checked === true) {
          accumulator.push(parseInt(chk.value))
        }
        return accumulator
      },
      []
    )
    this.currentReferenceTypeOrdinals = selectedReferenceTypes
    this.updateFilterCriteria()
  }

  updateFilterCriteria() {
    // first, show all of them
    this.showAllDocuments()
    // 2nd, hide technical areas other than the currently selected one
    const taID = this.currentTechnicalAreaId
    if (taID > 0) {
      $(".document.row", this.element).not(`.technical-area-${taID}`).hide()
    }
    // 3rd, hide any rows that are not of any of the currently checked reference types
    const classes = this.currentReferenceTypeOrdinals.map(
      (ordinal) => `.reference-type-${ordinal}`
    )
    if (classes.length > 0) {
      const classes_str = classes.join(", ")
      $(".document.row", this.element).not(classes_str).hide()
    }
    // lastly, update the other dynamic page elements
    this.updateDocumentCountDisplay()
    this.updateFilterCriteriaDisplay()
  }

  updateFilterCriteriaDisplay() {
    this.clearFilterCriteriaDisplay()
    if (this.currentTechnicalAreaId) {
      this.putFilterPillForTechnicalArea(this.currentTechnicalAreaId)
    }
    if (this.currentReferenceTypeOrdinals) {
      this.putFilterPillsForReferenceTypes(this.currentReferenceTypeOrdinals)
    }
  }

  clearFilterCriteriaDisplay() {
    $(this.filterCriteriaDisplayTarget).empty()
  }

  putFilterPillForTechnicalArea(technicalAreaId) {
    const technicalArea = this.technicalAreaForId(technicalAreaId)
    if (technicalArea) {
      $(this.filterCriteriaDisplayTarget).append(
        this.makePillBadgeForTechnicalArea(technicalArea.text)
      )
    }
  }

  putFilterPillsForReferenceTypes(referenceTypeOrdinals) {
    referenceTypeOrdinals.forEach((referenceTypeOrdinal) => {
      const idOfReferenceTypeCheckbox = $(
        `input[type=checkbox][value=${referenceTypeOrdinal}]`,
        this.element
      ).attr("id")
      const labelText = $(
        `label[for=${idOfReferenceTypeCheckbox}]`,
        this.element
      ).text()
      $(this.filterCriteriaDisplayTarget).append(
        this.makePillBadgeForReferenceType(labelText, referenceTypeOrdinal)
      )
    })
  }

  makePillBadgeForTechnicalArea(text) {
    return this.makePillBadge(text, "removeFilterCriterionOfTechnicalArea")
  }

  makePillBadgeForReferenceType(text, referenceTypeOrdinal) {
    return this.makePillBadge(
      text,
      `removeFilterCriterionOfReferenceType${referenceTypeOrdinal}`
    )
  }

  makePillBadge(text, methodName) {
    const templateHtml = $(this.templateSelector).html()
    const compiledTemplate = Hogan.compile(templateHtml)
    const templateData = { text: text, methodName: methodName }
    return compiledTemplate.render(templateData)
  }

  technicalAreaForId(taId) {
    return this.technicalAreas.find((ta) => ta.id === taId)
  }

  removeFilterCriterionOfTechnicalArea() {
    this.currentTechnicalAreaId = null
    $(this.technicalAreaSelectTarget).val(null)
    this.refreshTheChosenMenu()
    this.updateFilterCriteria()
  }

  removeFilterCriterionOfReferenceTypeForOrdinal(referenceTypeOrdinal) {
    const $elCheckbox = $(
      `input[type=checkbox][value=${referenceTypeOrdinal}]`,
      this.element
    )
    this.currentReferenceTypeOrdinals.splice(
      this.currentReferenceTypeOrdinals.indexOf(referenceTypeOrdinal),
      1
    )
    $elCheckbox.prop("checked", false)
    this.updateFilterCriteria()
  }

  refreshTheChosenMenu() {
    // this is needed to update the chosen menu UI
    $(this.technicalAreaSelectTarget).trigger("chosen:updated")
  }

  removeFilterCriterionOfReferenceType1() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(1)
  }

  removeFilterCriterionOfReferenceType2() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(2)
  }

  removeFilterCriterionOfReferenceType3() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(3)
  }

  removeFilterCriterionOfReferenceType4() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(4)
  }

  removeFilterCriterionOfReferenceType5() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(5)
  }

  removeFilterCriterionOfReferenceType6() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(6)
  }

  removeFilterCriterionOfReferenceType7() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(7)
  }

  removeFilterCriterionOfReferenceType8() {
    this.removeFilterCriterionOfReferenceTypeForOrdinal(8)
  }
}
