import React, { useEffect } from "react"
import $ from "jquery"
import { useDispatch } from "react-redux"
import { setSelectedChartTabIndex } from "../../config/actions"
import BarChartByTechnicalArea from "./BarChartByTechnicalArea"
import BarChartByActionType from "./BarChartByActionType"
import InfoPane from "./InfoPane"

const tabSelector = 'a[data-toggle="tab"]'

const ChartCard = () => {
  const dispatch = useDispatch()
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
    <div className="plan card">
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
