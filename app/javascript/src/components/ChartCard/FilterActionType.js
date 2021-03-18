import React from "react"
import { useDispatch, useSelector } from "react-redux"
import {
  getPlanChartLabels,
  getSelectedActionTypeOrdinal,
  getSelectedChartTabIndex,
} from "../../config/selectors"
import Dropdown from "react-bootstrap/Dropdown"
import { deselectActionType, selectActionType } from "../../config/actions"
import { makeDropdownItem } from "../../config/helpers"

const FilterActionType = () => {
  const selectedChartTabIndex = useSelector((state) =>
    getSelectedChartTabIndex(state)
  )
  const selectedActionTypeOrdinal = useSelector((state) =>
    getSelectedActionTypeOrdinal(state)
  )
  const barChartLabels = useSelector((state) => getPlanChartLabels(state))[
    selectedChartTabIndex
  ]

  const dispatch = useDispatch()

  const onSelectActionType = (eventKey) => {
    if (eventKey === "ALL") {
      dispatch(deselectActionType())
    } else {
      dispatch(selectActionType(parseInt(eventKey, 10) - 1))
    }
  }

  const allItem = makeDropdownItem("All", "ALL")
  const items = barChartLabels.map((label, i) => makeDropdownItem(label, i + 1))
  const selectedText = selectedActionTypeOrdinal
    ? barChartLabels[selectedActionTypeOrdinal - 1]
    : "All"

  return (
    <div className="row dropdown-filter">
      <div className="col">
        <Dropdown
          onSelect={onSelectActionType}
          id="dropdown-filter-action-type"
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

export default FilterActionType
