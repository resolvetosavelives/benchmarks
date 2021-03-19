import React from "react"
import { useDispatch, useSelector } from "react-redux"
import {
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
  const barChartLabels = useSelector((state) => getPlanChartLabels(state))[
    selectedChartTabIndex
  ]
  const dispatch = useDispatch()

  const onSelectTechnicalArea = (eventKey) => {
    if (eventKey === "ALL") {
      dispatch(deselectTechnicalArea())
    } else {
      dispatch(selectTechnicalArea(parseInt(eventKey, 10)))
    }
  }

  const allItem = makeDropdownItem("All", "ALL")
  const items = barChartLabels.map((label, i) => makeDropdownItem(label, i + 1))
  const selectedText = selectedTechnicalAreaId
    ? barChartLabels[selectedTechnicalAreaId - 1]
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
