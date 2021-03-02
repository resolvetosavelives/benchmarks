import React, { useEffect } from "react"
import $ from "jquery"
import { useDispatch, useSelector } from "react-redux"
import { setSelectedChartTabIndex } from "../../config/actions"
import BarChartByTechnicalArea from "./BarChartByTechnicalArea"
import BarChartByActionType from "./BarChartByActionType"
import InfoPane from "./InfoPane"
import { getPlan, makeGetDiseaseForDiseaseId } from "../../config/selectors"

const tabSelector = 'a[data-toggle="tab"]'

const ChartCard = () => {
  const dispatch = useDispatch()
  const plan = useSelector((state) => getPlan(state))
  const getDiseaseForDiseaseId0 = makeGetDiseaseForDiseaseId(
    plan.disease_ids.length > 0 ? plan.disease_ids[0] : -1
  )
  const disease0 = useSelector((state) => getDiseaseForDiseaseId0(state))
  const getDiseaseForDiseaseId1 = makeGetDiseaseForDiseaseId(
    plan.disease_ids.length > 1 ? plan.disease_ids[1] : -1
  )
  const disease1 = useSelector((state) => getDiseaseForDiseaseId1(state))
  let diseaseSeriesClass = "diseases"
  if (plan.disease_ids.length === 0) {
    diseaseSeriesClass += "-none"
  } else {
    diseaseSeriesClass += `-${disease0.name}`
    if (plan.disease_ids.length > 1) {
      diseaseSeriesClass += `-${disease1.name}`
    }
  }

  useEffect(() => {
    $(tabSelector).on("show.bs.tab", function (e) {
      const selectedTabDomNode = e.target
      const tabIndex = $(tabSelector).index(selectedTabDomNode)
      dispatch(setSelectedChartTabIndex(tabIndex))
    })
    return function cleanup() {
      $(tabSelector).off()
    }
  })
  return (
    <div className={`plan card ${diseaseSeriesClass}`}>
      <ul className="nav nav-tabs pt-3" role="tablist">
        <li className="nav-item px-2">
          <a
            className="nav-link active"
            data-toggle="tab"
            href="#tabContentForTechnicalArea"
            id="tabForTechnicalArea"
            role="tab"
            aria-controls="technical-area"
            aria-selected="true"
          >
            Technical Area
          </a>
        </li>
        <li className="nav-item px-2">
          <a
            className="nav-link"
            data-toggle="tab"
            href="#tabContentForActionType"
            id="tabForActionType"
            role="tab"
            aria-controls="action-type"
            aria-selected="false"
          >
            Action Type
          </a>
        </li>
      </ul>

      <div className="row tab-content my-3">
        <div
          id="tabContentForTechnicalArea"
          aria-labelledby="tabForTechnicalArea"
          role="tabpanel"
          className="col-auto tab-pane show active"
        >
          <div className="row no-gutters">
            {
              // Left Col
            }
            <div className="chart-pane col-12 col-xl-8 d-flex flex-column align-items-center">
              <h6 className="my-3">Actions per benchmark technical area</h6>
              {
                // Actual Chart, by Technical Area
              }
              <BarChartByTechnicalArea width="100%" height="240" />
            </div>

            {
              // Right Col
            }
            <InfoPane />
          </div>
        </div>

        <div
          id="tabContentForActionType"
          aria-labelledby="tabForActionType"
          role="tabpanel"
          className="col-auto tab-pane"
        >
          <div className="row no-gutters">
            {
              // Left Col
            }
            <div className="chart-pane col-12 col-xl-8 d-flex flex-column align-items-center">
              <h6 className="my-3">Actions per action type</h6>
              {
                // Actual Chart, by Action Type
              }
              <BarChartByActionType width="100%" height="240" />
            </div>

            {
              // Right Col
            }
            <InfoPane />
          </div>
        </div>
      </div>
    </div>
  )
}

export default ChartCard
