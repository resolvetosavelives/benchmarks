import React from "react"
import { useSelector } from "react-redux"
import { getPlanDiseases } from "../../config/selectors"
import BarChartLegendDiseaseLabel from "./BarChartLegendDiseaseLabel"

const BarChartLegend = () => {
  const planDiseases = useSelector((state) => getPlanDiseases(state))

  const diseaseLabelsHTML = planDiseases.map((disease) => {
    return (
      <BarChartLegendDiseaseLabel
        disease={disease}
        key={`disease-label-${disease.name}`}
      />
    )
  })

  return (
    <div className="row py-2 px-4">
      <ul className="ct-legend list-group list-group-horizontal col px-1">
        <li className="ct-series-health-security">Health security</li>
        {diseaseLabelsHTML}
      </ul>
    </div>
  )
}

export default BarChartLegend
