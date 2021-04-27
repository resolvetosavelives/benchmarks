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
      <div className="d-flex align-items-center justify-content-center pr-2">
        <span
          className={`badge badge-pill align-middle badge-rounded-circle color-value-${currentScore}`}
        >
          <span>{currentScore}</span>
        </span>
        <img className="mx-1" src={rightArrow} />
        <span
          className={`badge badge-pill align-middle badge-rounded-circle color-value-${targetScore}`}
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
