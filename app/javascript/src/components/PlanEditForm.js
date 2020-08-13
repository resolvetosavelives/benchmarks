import React from "react"
import { useDispatch, useSelector } from "react-redux"
import PropTypes from "prop-types"
import ChartCard from "./ChartCard/ChartCard"
import ActionList from "./List/ActionList"
import {
  getPlan,
  getFormAuthenticityToken,
  getFormActionUrl,
  getPlanActionIds,
} from "../config/selectors"
import { updatePlanName } from "../config/actions"
import Nudges from "./Nudges/Nudges"

const formRef = React.createRef()
const submitButtonRef = React.createRef()
const debounceWaitMs = 300
let debounceTimerId

const debouncedUpdatePlanName = (planName, dispatch) => {
  if (debounceTimerId) {
    clearTimeout(debounceTimerId)
  }
  debounceTimerId = setTimeout(() => {
    debounceTimerId = null
    const isValid = validatePlanName(formRef, submitButtonRef)
    if (isValid) {
      dispatch(updatePlanName(planName))
    }
  }, debounceWaitMs)
  return true
}

const validatePlanName = (formRef, submitRef) => {
  const formDomNode = formRef.current
  const submitDomNode = submitRef.current
  const formIsValid = formDomNode.checkValidity()
  if (formIsValid === false) {
    setFormIsInvalid(formDomNode, submitDomNode)
  } else {
    setFormIsValid(formDomNode, submitDomNode)
  }
  return formIsValid
}

const setFormIsValid = function (formDomNode, submitDomNode) {
  submitDomNode.removeAttribute("disabled")
  formDomNode.removeAttribute("disabled")
  formDomNode.classList.add("was-validated")
}

const setFormIsInvalid = function (formDomNode, submitDomNode) {
  submitDomNode.setAttribute("disabled", "disabled")
  formDomNode.setAttribute("disabled", "disabled")
  formDomNode.classList.add("was-validated")
}

const updateStateFromServer = (stateToUpdateLater, plan, planActionIdsJson) => {
  stateToUpdateLater.plan = JSON.stringify(plan)
  stateToUpdateLater.planActionIds = planActionIdsJson
}

const PlanEditForm = (props) => {
  const formActionUrl = getFormActionUrl()
  const formAuthenticityToken = getFormAuthenticityToken()
  const dispatch = useDispatch()
  const plan = useSelector((state) => getPlan(state))
  const planNameFromStore = plan.name
  const planActionIds = useSelector((state) => getPlanActionIds(state))
  const planActionIdsJson = JSON.stringify(planActionIds)
  updateStateFromServer(props.stateToUpdateLater, plan, planActionIdsJson)
  return (
    <div className="row">
      <div className="col plan-container">
        <form
          className="needs-validation"
          acceptCharset="UTF-8"
          method="post"
          action={formActionUrl}
          ref={formRef}
        >
          <input name="utf8" type="hidden" value="✓" />
          <input type="hidden" name="_method" value="patch" />
          <input
            type="hidden"
            name="authenticity_token"
            defaultValue={formAuthenticityToken}
          />
          <input
            type="hidden"
            id="plan_benchmark_action_ids"
            name="plan[benchmark_action_ids]"
            autoComplete="off"
            defaultValue={planActionIdsJson}
          />

          <div className="row full-width stick-to-top bg-dark-blue">
            <div className="container mx-auto row no-gutters justify-content-between p-2">
              <div className="col-lg-5 m-2 form-group alt-header">
                <input
                  className="plan-name form-control"
                  required="required"
                  type="text"
                  defaultValue={planNameFromStore}
                  name="plan[name]"
                  id="plan_name"
                  autoComplete="off"
                  onChange={(e) =>
                    debouncedUpdatePlanName(e.target.value, dispatch)
                  }
                />
                <div className="invalid-feedback">Cannot be empty</div>
              </div>

              <div className="col-auto m-2">
                <input
                  type="submit"
                  name="commit"
                  value="Save Plan"
                  data-disable-with="Save Plan"
                  className="plan-save btn btn-orange w-100"
                  ref={submitButtonRef}
                />
              </div>
            </div>
          </div>

          <div className="row">
            <div className="col mt-4">
              <ChartCard />
            </div>
          </div>

          <Nudges />

          <div className="row action-list-component">
            <ActionList />
          </div>
        </form>
      </div>
    </div>
  )
}

PlanEditForm.propTypes = {
  stateToUpdateLater: PropTypes.object.isRequired,
}

export default PlanEditForm
