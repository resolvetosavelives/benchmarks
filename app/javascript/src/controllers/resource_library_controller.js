import {Controller} from "stimulus"
import $ from "jquery"

export default class extends Controller {
    static targets = ["filterForm", "documentCount", "technicalAreaSelect"]

    connect() {
        console.log("GVT: connect..")
        $(this.technicalAreaSelectTarget).chosen({no_results_text: "No countries match"})
        $(this.technicalAreaSelectTarget).on("change", this.handleSelectTechnicalArea.bind(this))
        this.updateDocumentCountDisplay()
    }

    handleSelectTechnicalArea(jqEvent, selectedValue) {
        const taID = selectedValue.selected
        $(".document.row", this.element).not(`.technical-area-${taID}`).hide()
        $(".document.row", this.element).filter(`.technical-area-${taID}`).show()
        this.updateDocumentCountDisplay()
    }

    updateDocumentCountDisplay() {
        const newCount = $(".document.row:visible", this.element).length
        const resourceWord = newCount === 1 ? "resource": "resources"
        const countDisplayText = `${newCount} ${resourceWord}`
        $(this.documentCountTarget).html(countDisplayText)
    }

    resetForm(event) {
        console.log("GVT: resetForm..")
        event.preventDefault()
        event.stopPropagation()
        this.showAllDocuments()
        $(this.technicalAreaSelectTarget).val(null)
        $(this.technicalAreaSelectTarget).trigger("chosen:updated");
    }

    showAllDocuments() {
        $(".document.row", this.element).show()
        this.updateDocumentCountDisplay()
    }
}
