import React from "react"
import { useSelector } from "react-redux"
import { getPlan, makeGetDisplayForDiseaseId } from "../../config/selectors"

const BarChartLegend = () => {
  const plan = useSelector((state) => getPlan(state))
  const getDisplayForDiseaseId = makeGetDisplayForDiseaseId(plan.disease_ids)
  const labelSeriesB = useSelector((state) => getDisplayForDiseaseId(state))
  const labelSeriesBHtml = labelSeriesB ? (
    <li className="ct-series-b">{labelSeriesB} specific</li>
  ) : null

  return (
    <div className="row card d-flex flex-column px-2 py-2 m-0">
      <div className="col">
        <strong>Key</strong>
      </div>
      <ul className="ct-legend col m-0">
        <li className="ct-series-a">Health security</li>
        {labelSeriesBHtml}
      </ul>
    </div>
  )
}

export default BarChartLegend
