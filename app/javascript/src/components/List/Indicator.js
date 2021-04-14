import React from "react"
import PropTypes from "prop-types"
import IndicatorActionList from "./IndicatorActionList"
import rightArrow from "./right-arrow.svg"

const Indicator = (props) => {
  const indicator = props.indicator
  const currentScore = "3"
  const targetScore = "4"

  return (
    <div
      className="benchmark-container col"
      data-benchmark-indicator-display-abbrev={indicator.display_abbreviation}
    >
      <div className="row bg-light-gray px-2 header">
        <div className="col-1 d-flex flex-row align-items-center justify-content-end py-2 py-md-0">
          <span className="badge badge-pill badge-primary align-middle rounded-circle mx-auto">
            {currentScore}
          </span>
          <img src={rightArrow} />
          <div className="badge badge-pill badge-secondary align-middle">
            {targetScore}
          </div>
        </div>
        <div className="col-11">
          <b>Benchmark {indicator.display_abbreviation}:</b>
          &nbsp;
          {indicator.text}
        </div>
      </div>
      <IndicatorActionList indicator={indicator} />
    </div>
  )
}

Indicator.propTypes = {
  indicator: PropTypes.object.isRequired,
}

export default Indicator
