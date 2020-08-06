import React from "react"
import BarChartByTechnicalArea from "./BarChartByTechnicalArea"
import BarChartByActionType from "./BarChartByActionType"
import NudgeByTechnicalArea from "./NudgeByTechnicalArea"
import NudgeByActionType from "./NudgeByActionType"

const ChartCard = () => {
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

      <div className="row tab-content">
        <div
          id="tabContentForTechnicalArea"
          aria-labelledby="tabForTechnicalArea"
          role="tabpanel"
          className="col-auto tab-pane fade show active"
        >
          <div className="row no-gutters">
            {
              // Left Col
            }
            <div className="chart-pane col-12 col-lg d-flex flex-column align-items-center">
              <h6 className="my-3">Actions per benchmark technical area</h6>
              {
                // Actual Chart, by Technical Area
              }
              <BarChartByTechnicalArea width="700" height="240" />
            </div>

            {
              // Right Col: Nudge by Technical Area
            }
            <NudgeByTechnicalArea />
          </div>
        </div>

        <div
          id="tabContentForActionType"
          aria-labelledby="tabForActionType"
          role="tabpanel"
          className="col-auto tab-pane fade"
        >
          <div className="row no-gutters">
            {
              // Left Col
            }
            <div className="chart-pane col-12 col-lg d-flex mx-auto flex-column align-items-center">
              <h6 className="my-3">Actions per action type</h6>
              {
                // Actual Chart, by Action Type
              }
              <BarChartByActionType width="700" height="240" />
            </div>

            {
              // Right Col
            }
            {<NudgeByActionType />}
          </div>
        </div>
      </div>
    </div>
  )
}

export default ChartCard
