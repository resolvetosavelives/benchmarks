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
    <div className="row card d-flex flex-column px-2 py-2 m-0">
      <div className="col">
        <strong>Key</strong>
      </div>
      <ul className="ct-legend col m-0">
        <li className="ct-series-health-security">Health security</li>
        {diseaseLabelsHTML}
      </ul>
    </div>
  )
}

export default BarChartLegend
