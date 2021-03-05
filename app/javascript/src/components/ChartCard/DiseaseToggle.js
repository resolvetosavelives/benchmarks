import React from "react"
import { useDispatch, useSelector } from "react-redux"
import { makeGetDiseaseIsShowingForDisease } from "../../config/selectors"
import { toggleDiseaseShowing } from "../../config/actions"
import PropTypes from "prop-types"

const DiseaseToggle = (props) => {
  const disease = props.disease
  const getIsDiseaseShowing = makeGetDiseaseIsShowingForDisease(disease)
  const isDiseaseShowing = useSelector((state) => getIsDiseaseShowing(state))
  const dispatch = useDispatch()

  const toggleDisease = () => {
    dispatch(toggleDiseaseShowing(disease))
  }

  const id = `disease-${disease.name}`

  return (
    <div className="col">
      <input
        type="checkbox"
        id={id}
        onChange={toggleDisease}
        defaultChecked={isDiseaseShowing}
      />
      <label htmlFor={id} className="mx-2">
        {disease.display}
      </label>
    </div>
  )
}

DiseaseToggle.propTypes = {
  disease: PropTypes.object.isRequired,
}

export default DiseaseToggle
