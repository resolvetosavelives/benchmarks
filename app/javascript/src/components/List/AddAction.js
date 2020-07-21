import React, { useState } from "react"
import PropTypes from "prop-types"
import { shallowEqual, useDispatch, useSelector } from "react-redux"
import Select from "react-select"
import { addActionToIndicator } from "../../config/actions"
import { getActionMap } from "../../config/selectors"

const selectAction = (action, indicator, dispatch) => {
  dispatch(addActionToIndicator(action.id, indicator.id))
}

const AddAction = (props) => {
  const indicator = props.indicator
  const dispatch = useDispatch()
  const actions = useSelector((state) => getActionMap(state), shallowEqual)
  const planActionIdsNotInIndicator = useSelector(
    (state) => state.planActionIdsNotInIndicator
  )
  const actionIds = planActionIdsNotInIndicator[indicator.id]
  const actionDataObjects = actionIds.map((actionId) => actions[actionId])
  const [value, setValue] = useState("")

  const customStyles = {
    control: (provided) => ({
      ...provided,
      border: "none",
    }),
    dropdownIndicator: (provided) => ({
      ...provided,
      opacity: 0,
      maxWidth: 0,
    }),
    indicatorSeparator: (provided) => ({
      ...provided,
      opacity: 0,
      maxWidth: 0,
    }),
  }

  return (
    <div className="row action-form">
      <Select
        options={actionDataObjects}
        getOptionLabel={(action) => action.text}
        className="w-100"
        styles={customStyles}
        placeholder="+ Add Action"
        onChange={(action) => {
          selectAction(action, indicator, dispatch)
          setValue("")
        }}
        value={value}
      />
    </div>
  )
}

AddAction.propTypes = {
  indicator: PropTypes.object.isRequired,
}

export default AddAction
