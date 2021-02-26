import React from "react"
import { useSelector } from "react-redux"
import { getPlan } from "../../config/selectors"
import BarChartLegendLabel from "./BarChartLegendLabel"

const BarChartLegend = () => {
  const plan = useSelector((state) => getPlan(state))

  const diseaseLabelsHTML = plan.disease_ids.map((diseaseId) => {
    return (
      <BarChartLegendLabel
        diseaseId={diseaseId}
        key={`disease-label-${diseaseId}`}
      />
    )
  })

  return (
    <div className="row card d-flex flex-column px-2 py-2 m-0">
      <div className="col">
        <strong>Key</strong>
      </div>
      <ul className="ct-legend col m-0">
        <li className="ct-series-a">Health security</li>
        {diseaseLabelsHTML}
      </ul>
    </div>
  )
}

export default BarChartLegend
