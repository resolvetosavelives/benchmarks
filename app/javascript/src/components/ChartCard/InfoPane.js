import React from "react"
import ActionCount from "./ActionCount"
import DiseaseToggles from "./DiseaseToggles"
import Filters from "./Filters"

// this is the best we have found so far:
//   col-12 col-xl-auto
// this is what it used to be before UI Rearrangement
//   col-12 col-md

const InfoPane = () => {
  return (
    <div className="info-pane-component col-12 col-xl-4">
      <Filters />
      <DiseaseToggles />
      <ActionCount />
    </div>
  )
}

export default InfoPane
