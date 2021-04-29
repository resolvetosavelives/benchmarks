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
    <div className="col-12 col-md-6 col-xl-12">
      <div className="row no-gutters d-flex flex-column flex-md-row justify-content-between mb-0">
        <div className="col">
          <strong>{title}</strong>
        </div>
        <div className="col text-right">
          <ClearFilters />
        </div>
      </div>
      <div className="row mb-0">
        <div className="col">{filterComponent}</div>
      </div>
    </div>
  )
}

export default Filters
