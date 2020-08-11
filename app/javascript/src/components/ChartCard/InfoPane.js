import React from "react"
import ActionCount from "./ActionCount"
import ClearFilters from "./ClearFilters"
import InfluenzaToggle from "./InfluenzaToggle"

// this is the best we have found so far:
//   col-12 col-xl-auto
// this is what it used to be before UI Rearrangement
//   col-12 col-md

const InfoPane = () => {
  return (
    <div className="info-pane-component col-12 col-xl-auto d-flex flex-column align-self-start">
      <div className="row d-flex flex-row justify-content-between">
        <ActionCount />
        <ClearFilters />
      </div>
      <InfluenzaToggle />
    </div>
  )
}

export default InfoPane
