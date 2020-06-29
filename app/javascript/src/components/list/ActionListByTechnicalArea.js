import React from "react"
import { useSelector } from "react-redux"
import TechnicalArea from "./TechnicalArea"

const ActionListByTechnicalArea = () => {
  const technicalAreas = useSelector((state) => state.technicalAreas)
  const selectedTechnicalAreaId = useSelector(
    (state) => state.selectedTechnicalAreaId
  )
  let filteredTechnicalAreas = technicalAreas.filter((technicalArea) => {
    if (parseInt(selectedTechnicalAreaId)) {
      return selectedTechnicalAreaId === technicalArea.id
    } else {
      return true
    }
  })
  const technicalAreaComponents = filteredTechnicalAreas.map(
    (technicalArea) => {
      return (
        <TechnicalArea technicalArea={technicalArea} key={technicalArea.id} />
      )
    }
  )
  return (
    <div id="action-list-by-tech-container" className="col-auto w-100">
      {technicalAreaComponents}
    </div>
  )
}

export default ActionListByTechnicalArea
