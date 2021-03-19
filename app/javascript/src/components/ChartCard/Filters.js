import React from "react"
import ClearFilters from "./ClearFilters"
import FilterTechnicalArea from "./FilterTechnicalArea"
import { getSelectedChartTabIndex } from "../../config/selectors"
import { useSelector } from "react-redux"
import ActionTypeFilter from "./FilterActionType"

const Filters = () => {
  const selectedChartTabIndex = useSelector((state) =>
    getSelectedChartTabIndex(state)
  )
  let title, filterComponent
  if (selectedChartTabIndex === 0) {
    title = "Technical area filter"
    filterComponent = <FilterTechnicalArea />
  } else {
    title = "Action type filter"
    filterComponent = <ActionTypeFilter />
  }

  return (
    <>
      <div className="row d-flex justify-content-between mb-1">
        <div className="col">
          <strong>{title}</strong>
        </div>
        <div className="col text-right">
          <ClearFilters />
        </div>
      </div>
      <div className="row">
        <div className="col">{filterComponent}</div>
      </div>
    </>
  )
}

export default Filters
