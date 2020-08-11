import React from "react"
import { useDispatch, useSelector } from "react-redux"
import { getIsInfluenzaShowing, isPlanInfluenza } from "../../config/selectors"
import { toggleInfluenzaShowing } from "../../config/actions"

const InfluenzaToggle = () => {
  const dispatch = useDispatch()
  const eventHandler = () => {
    dispatch(toggleInfluenzaShowing())
  }
  const isInfluenza = useSelector((state) => isPlanInfluenza(state))
  const isInfluenzaShowing = useSelector((state) =>
    getIsInfluenzaShowing(state)
  )
  if (!isInfluenza) {
    return null
  }

  return (
    <div className="row d-flex flex-column mb-4">
      <div className="col">
        <strong>Show diseases</strong>
      </div>
      <div className="col my-1">
        <input
          type="checkbox"
          id="influenza"
          onChange={eventHandler}
          defaultChecked={isInfluenzaShowing}
        />
        <label htmlFor="influenza" className="mx-2">
          Influenza
        </label>
      </div>
    </div>
  )
}

export default InfluenzaToggle
