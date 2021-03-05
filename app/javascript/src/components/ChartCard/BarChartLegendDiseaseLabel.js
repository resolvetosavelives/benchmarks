import React from "react"
import PropTypes from "prop-types"

const BarChartLegendDiseaseLabel = (props) => {
  const disease = props.disease
  return (
    <li className={`ct-series-${disease.name}`}>{disease.display} specific</li>
  )
}

BarChartLegendDiseaseLabel.propTypes = {
  disease: PropTypes.object.isRequired,
}

export default BarChartLegendDiseaseLabel
