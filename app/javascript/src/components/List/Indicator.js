import React from "react"
import PropTypes from "prop-types"
import IndicatorActionList from "./IndicatorActionList"
import ScoreToGoal from "./ScoreToGoal"

const Indicator = (props) => {
  const indicator = props.indicator

  return (
    <div
      className="benchmark-container"
      data-benchmark-indicator-display-abbrev={indicator.display_abbreviation}
    >
      <div className="row py-3 bg-light-gray header d-flex flex-column flex-md-row">
        <div className="col-auto my-1 pr-0 d-flex justify-content-left align-items-center">
          <ScoreToGoal indicator={indicator} />
        </div>
        <div className="col my-1">
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
