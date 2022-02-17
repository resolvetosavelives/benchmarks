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
    this.documents = $(".document.row", this.element).clone(true)

    this.observeScrolling()
    this.updateDocumentCountDisplay()
    this.appearOnScroll()
  }

  observeScrolling() {
    const showMore = this.showMore.bind(this)
    this.observer = new IntersectionObserver((entries) => {
      if (entries[0].intersectionRatio >= 0) showMore()
    })
    this.observer.observe(document.querySelector(".copyright"))
  }

  appearOnScroll() {
    $(".document.row", this.element).hide()
    this.showMore()
  }

  showMore() {
    $(".document.row:hidden").slice(0, 10).show()
  }

  handleSelectTechnicalArea(jqEvent, selectedValue) {
    const taID = parseInt(selectedValue.selected)
    this.currentTechnicalAreaId = taID
    this.updateFilterCriteria()
  }

  updateDocumentCountDisplay() {
    const newCount = $(".document.row", this.element).length
    const referenceWord = newCount === 1 ? "reference" : "references"
    const countDisplayText = `<b>${newCount}</b> ${referenceWord}`
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
    $(".document-container", this.element).empty().append(this.documents)
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
      $(".document.row", this.element).not(`.technical-area-${taID}`).remove()
    }
    // 3rd, hide any rows that are not of any of the currently checked reference types
    const classes = this.currentReferenceTypeOrdinals.map(
      (ordinal) => `.reference-type-${ordinal}`
    )
    if (classes.length > 0) {
      const classes_str = classes.join(", ")
      $(".document.row", this.element).not(classes_str).remove()
    }
    // lastly, update the other dynamic page elements
    this.updateDocumentCountDisplay()
    this.appearOnScroll()
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
    return this.makePillBadge(
      text,
      "removeFilterCriterionOfTechnicalArea",
      null
    )
  }

  makePillBadgeForReferenceType(text, referenceTypeOrdinal) {
    return this.makePillBadge(
      text,
      "removeFilterCriterionOfReferenceViaCloseButton",
      referenceTypeOrdinal
    )
  }

  makePillBadge(text, methodName, ordinalOrNull) {
    const templateHtml = $(this.templateSelector).html()
    const compiledTemplate = Hogan.compile(templateHtml)
    const templateData = {
      text: text,
      methodName: methodName,
      ordinal: ordinalOrNull,
    }
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

  removeFilterCriterionOfReferenceViaCloseButton(event) {
    const referenceTypeOrdinal = $(event.currentTarget).data("ordinal")
    this.removeFilterCriterionOfReferenceTypeForOrdinal(referenceTypeOrdinal)
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
}
