import React from "react"
import PropTypes from "prop-types"
import IndicatorActionList from "./IndicatorActionList"
import ScoreToGoal from "./ScoreToGoal"

const Indicator = (props) => {
  const indicator = props.indicator

  return (
    <div
      className="benchmark-container col"
      data-benchmark-indicator-display-abbrev={indicator.display_abbreviation}
    >
      <div className="row bg-light-gray pl-3 pr-3 header">
        <ScoreToGoal indicator={indicator} />
        <div className="col pl-1">
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
