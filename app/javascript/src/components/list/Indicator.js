import React from "react"
import PropTypes from "prop-types"
import IndicatorActionList from "./IndicatorActionList"

const Indicator = (props) => {
  const indicator = props.indicator

  return (
    <div
      className="benchmark-container col"
      data-benchmark-indicator-display-abbrev={indicator.display_abbreviation}
    >
      <div className="row bg-light-gray px-2 header">
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
