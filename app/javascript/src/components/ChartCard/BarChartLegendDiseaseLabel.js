import React from "react"
import PropTypes from "prop-types"
import { makeGetDiseaseForDiseaseId } from "../../config/selectors"
import { useSelector } from "react-redux"

const BarChartLegendDiseaseLabel = (props) => {
  const diseaseId = props.diseaseId
  const getDisease = makeGetDiseaseForDiseaseId(diseaseId)
  const disease = useSelector((state) => getDisease(state))
  return (
    <li className={`ct-series-${disease.name}`}>{disease.display} specific</li>
  )
}

BarChartLegendDiseaseLabel.propTypes = {
  diseaseId: PropTypes.number.isRequired,
}

export default BarChartLegendDiseaseLabel
