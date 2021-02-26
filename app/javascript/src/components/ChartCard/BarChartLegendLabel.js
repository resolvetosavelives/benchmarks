import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import { makeGetDisplayForDiseaseId } from "../../config/selectors"
import { makeGetNameForDiseaseId } from "../../config/selectors"

const BarChartLegendLabel = (props) => {
  const diseaseId = props.diseaseId
  const getDisplayForDiseaseId = makeGetDisplayForDiseaseId(diseaseId)
  const getNameForDiseaseId = makeGetNameForDiseaseId(diseaseId)
  const diseaseLabel = useSelector((state) => getDisplayForDiseaseId(state))
  const diseaseName = useSelector((state) => getNameForDiseaseId(state))

  return <li className={`ct-series-${diseaseName}`}>{diseaseLabel} specific</li>
}

BarChartLegendLabel.propTypes = {
  diseaseId: PropTypes.number.isRequired,
}

export default BarChartLegendLabel
