import {Controller} from "stimulus"
import $ from "jquery"
import Hogan from "hogan.js"

export default class extends Controller {
    static targets = ["filterForm", "documentCount", "technicalAreaSelect", "checkboxForResourceType", "filterCriteriaDisplay"]

    initialize() {
        this.resetState()
    }

    resetState() {
        this.currentTechnicalAreaId = null
        this.currentResourceTypeOrdinals = []
    }

    connect() {
        $(this.technicalAreaSelectTarget).chosen({no_results_text: "No countries match"})
        $(this.technicalAreaSelectTarget).on("change", this.handleSelectTechnicalArea.bind(this))
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
        const resourceWord = newCount === 1 ? "resource": "resources"
        const countDisplayText = `${newCount} ${resourceWord}`
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

    handleCheckboxToggle(event) {
        const selectedResourceTypes = this.checkboxForResourceTypeTargets.reduce((accumulator, chk) => {
            if (chk.checked === true) {
                accumulator.push(parseInt(chk.value))
            }
            return accumulator
        }, [])
        this.currentResourceTypeOrdinals = selectedResourceTypes
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
        // 3rd, hide any rows that are not of any of the currently checked resource types
        const classes = this.currentResourceTypeOrdinals.map(ordinal => `.resource-type-${ordinal}`)
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
        if (this.currentResourceTypeOrdinals) {
            this.putFilterPillsForResourceTypes(this.currentResourceTypeOrdinals)
        }
    }

    clearFilterCriteriaDisplay() {
        $(this.filterCriteriaDisplayTarget).empty()
    }

    putFilterPillForTechnicalArea(technicalAreaId) {
        const technicalArea = this.technicalAreaForId(technicalAreaId)
        if (technicalArea) {
            $(this.filterCriteriaDisplayTarget).append(this.makePillBadgeForTechnicalArea(technicalArea.text))
        }
    }

    putFilterPillsForResourceTypes(resourceTypeOrdinals) {
        resourceTypeOrdinals.forEach((resourceTypeOrdinal) => {
            const idOfResourceTypeCheckbox = $(`input[type=checkbox][value=${resourceTypeOrdinal}]`, this.element).attr("id")
            const labelText = $(`label[for=${idOfResourceTypeCheckbox}]`, this.element).text()
            $(this.filterCriteriaDisplayTarget).append(this.makePillBadgeForResourceType(labelText, resourceTypeOrdinal))
        })
    }

    makePillBadgeForTechnicalArea(text) {
        return this.makePillBadge(text, "removeFilterCriterionOfTechnicalArea")
    }

    makePillBadgeForResourceType(text, resourceTypeOrdinal) {
        return this.makePillBadge(text, `removeFilterCriterionOfResourceType${resourceTypeOrdinal}`)
    }

    makePillBadge(text, methodName) {
        const templateHtml = $(this.templateSelector).html()
        const compiledTemplate = Hogan.compile(templateHtml)
        const templateData = {text: text, methodName: methodName}
        return compiledTemplate.render(templateData)
    }

    technicalAreaForId(taId) {
        return this.technicalAreas.find(ta => ta.id === taId)
    }

    removeFilterCriterionOfTechnicalArea() {
        this.currentTechnicalAreaId = null
        $(this.technicalAreaSelectTarget).val(null)
        this.refreshTheChosenMenu()
        this.updateFilterCriteria()
    }

    removeFilterCriterionOfResourceTypeForOrdinal(resourceTypeOrdinal) {
        const $elCheckbox = $(`input[type=checkbox][value=${resourceTypeOrdinal}]`, this.element)
        this.currentResourceTypeOrdinals.splice(this.currentResourceTypeOrdinals.indexOf(resourceTypeOrdinal), 1)
        $elCheckbox.prop("checked", false)
        this.updateFilterCriteria()
    }

    refreshTheChosenMenu() {
        // this is needed to update the chosen menu UI
        $(this.technicalAreaSelectTarget).trigger("chosen:updated")
    }

    removeFilterCriterionOfResourceType1() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(1)
    }

    removeFilterCriterionOfResourceType2() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(2)
    }

    removeFilterCriterionOfResourceType3() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(3)
    }

    removeFilterCriterionOfResourceType4() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(4)
    }

    removeFilterCriterionOfResourceType5() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(5)
    }

    removeFilterCriterionOfResourceType6() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(6)
    }

    removeFilterCriterionOfResourceType7() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(7)
    }

    removeFilterCriterionOfResourceType8() {
        this.removeFilterCriterionOfResourceTypeForOrdinal(8)
    }
}
