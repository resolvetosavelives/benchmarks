import React from "react"
import PropTypes from "prop-types"
import { useSelector } from "react-redux"
import {
  getCurrentScoreForIndicator,
  getTargetScoreForIndicator,
} from "../../config/selectors"
import rightArrow from "./right-arrow.svg"

const ScoreToGoal = (props) => {
  const indicator = props.indicator
  const currentScore = useSelector((state) =>
    getCurrentScoreForIndicator(state, indicator)
  )
  const targetScore = useSelector((state) =>
    getTargetScoreForIndicator(state, indicator)
  )

  if (currentScore && targetScore) {
    return (
      <div className="col-2 d-flex align-items-center justify-content-center">
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
    )
  } else {
    return null
  }
}

ScoreToGoal.propTypes = {
  indicator: PropTypes.object.isRequired,
}

export default ScoreToGoal
