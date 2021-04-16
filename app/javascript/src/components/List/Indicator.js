import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getCurrentScoreForIndicator,
  getTargetScoreForIndicator,
} from "../../config/selectors"
import IndicatorActionList from "./IndicatorActionList"
import rightArrow from "./right-arrow.svg"

const Indicator = (props) => {
  const indicator = props.indicator
  const currentScore = useSelector((state) =>
    getCurrentScoreForIndicator(state, indicator)
  )
  const targetScore = useSelector((state) =>
    getTargetScoreForIndicator(state, indicator)
  )

  return (
    <div
      className="benchmark-container col"
      data-benchmark-indicator-display-abbrev={indicator.display_abbreviation}
    >
      <div className="row bg-light-gray px-2 header">
        <div className="col-10">
          <b>Benchmark {indicator.display_abbreviation}:</b>
          &nbsp;
          {indicator.text}
        </div>
        <div className="col-2">
          <span
            className={`badge badge-pill badge-primary align-middle badge-rounded-circle color-value-${currentScore} mx-1 px-2`}
          >
            <span>{currentScore}</span>
          </span>
          <img className="mx-1" src={rightArrow} />
          <span
            className={`badge badge-pill color-value-${targetScore}  align-middle badge-rounded-circle mx-1 px-2`}
          >
            <span>{targetScore}</span>
          </span>
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
