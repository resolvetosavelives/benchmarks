import React from "react"
import ActionCount from "./ActionCount"
import DiseaseToggles from "./DiseaseToggles"
import Filters from "./Filters"

const InfoPane = () => {
  return (
    <div className="info-pane-component col-12 order-first col-xl-4 order-xl-last">
      <Filters />
      <div className="row">
        <DiseaseToggles />
        <ActionCount />
      </div>
    </div>
  )
}

export default InfoPane
