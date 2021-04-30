import React from "react"
import { useSelector } from "react-redux"
import { getPlanDiseases } from "../../config/selectors"
import DiseaseToggle from "./DiseaseToggle"

const DiseaseToggles = () => {
  const planDiseases = useSelector((state) => getPlanDiseases(state))

  if (planDiseases.length === 0) {
    return null
  }

  const diseaseTogglesHTML = planDiseases.map((disease) => {
    return (
      <DiseaseToggle disease={disease} key={`disease-toggle-${disease.id}`} />
    )
  })

  return (
    <div className="col-7 col-md-3 col-xl-12 d-flex flex-column">
      <strong>Show diseases</strong>
      {diseaseTogglesHTML}
    </div>
  )
}

export default DiseaseToggles
