import React from "react"
import { useSelector } from "react-redux"
import { getPlan, makeGetDisplayForDiseaseId } from "../../config/selectors"

const BarChartLegend = () => {
  const plan = useSelector((state) => getPlan(state))
  const getDisplayForDiseaseId = makeGetDisplayForDiseaseId(plan.disease_ids)
  const labelSeriesB = useSelector((state) => getDisplayForDiseaseId(state))
  if (!labelSeriesB) {
    return null
  }

  return (
    <ul className="ct-legend">
      <li className="ct-series-a">Health security</li>
      <li className="ct-series-b">{labelSeriesB} specific</li>
    </ul>
  )
}

export default BarChartLegend
