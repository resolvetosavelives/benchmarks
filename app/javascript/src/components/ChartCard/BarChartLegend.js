import React from "react"
import { useSelector } from "react-redux"
import { getPlan, getDisplayForDiseaseId } from "../../config/selectors"

const BarChartLegend = () => {
  const plan = useSelector((state) => getPlan(state))
  if (plan.disease_ids.length === 0) {
    return null
  }

  const labelSeriesB = getDisplayForDiseaseId(plan.disease_ids[0])

  return (
    <ul className="ct-legend">
      <li className="ct-series-a">Health security</li>
      <li className="ct-series-b">{labelSeriesB} specific</li>
    </ul>
  )
}

export default BarChartLegend
