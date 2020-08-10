import React from "react"
import ActionCount from "./ActionCount"
import ClearFilters from "./ClearFilters"

// this is the best we have found so far:
//   col-12 col-xl-auto
// this is what it used to be before UI Rearrangement
//   col-12 col-md

const InfoPane = () => {
  return (
    <div className="info-pane-component col-12 col-xl-auto d-flex flex-column m-3">
      <div className="col d-flex flex-row justify-content-between">
        <ActionCount />
        <ClearFilters />
      </div>
    </div>
  )
}

export default InfoPane
