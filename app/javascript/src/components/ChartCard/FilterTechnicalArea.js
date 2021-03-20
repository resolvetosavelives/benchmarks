import React from "react"
import { useDispatch, useSelector } from "react-redux"
import {
  getAllTechnicalAreas,
  getPlanChartLabels,
  getSelectedChartTabIndex,
  getSelectedTechnicalAreaId,
} from "../../config/selectors"
import Dropdown from "react-bootstrap/Dropdown"
import {
  deselectTechnicalArea,
  selectTechnicalArea,
} from "../../config/actions"
import { makeDropdownItem } from "../../config/helpers"

const FilterTechnicalArea = () => {
  const selectedChartTabIndex = useSelector((state) =>
    getSelectedChartTabIndex(state)
  )
  const selectedTechnicalAreaId = useSelector((state) =>
    getSelectedTechnicalAreaId(state)
  )
  const technicalAreas = useSelector((state) => getAllTechnicalAreas(state))
  const barChartLabels = useSelector((state) => getPlanChartLabels(state))[
    selectedChartTabIndex
  ]
  const dispatch = useDispatch()

  const onSelectTechnicalArea = (eventKey) => {
    if (eventKey === "ALL") {
      dispatch(deselectTechnicalArea())
    } else {
      const technicalAreaId = technicalAreas[parseInt(eventKey, 10) - 1].id
      dispatch(selectTechnicalArea(technicalAreaId))
    }
  }

  const allItem = makeDropdownItem("All", "ALL")
  const items = barChartLabels.map((label, i) => makeDropdownItem(label, i + 1))
  const selectedText = selectedTechnicalAreaId
    ? barChartLabels[
        technicalAreas.findIndex(
          (technicalArea) => technicalArea.id === selectedTechnicalAreaId
        )
      ]
    : "All"

  return (
    <div className="row dropdown-filter">
      <div className="col">
        <Dropdown
          onSelect={onSelectTechnicalArea}
          id="dropdown-filter-technical-area"
        >
          <Dropdown.Toggle>{selectedText}</Dropdown.Toggle>
          <Dropdown.Menu>
            {allItem}
            {items}
          </Dropdown.Menu>
        </Dropdown>
      </div>
    </div>
  )
}

export default FilterTechnicalArea
