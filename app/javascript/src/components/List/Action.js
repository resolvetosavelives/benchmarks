import React, { useState } from "react"
import PropTypes from "prop-types"
import { deleteAnAction } from "../../config/actions"
import { getIndicatorMap } from "../../config/selectors"
import { useDispatch, useSelector } from "react-redux"
import ActionBadge from "./ActionBadge"
import ActionBadgePill from "./ActionBadgePill"
import caret from "./caret.svg"

const Action = (props) => {
  const action = props.action
  const dispatch = useDispatch()
  const indicatorMap = useSelector((state) => getIndicatorMap(state))
  const indicator = indicatorMap[action.benchmark_indicator_id]
  let [expanded, setExpanded] = useState(true)
  const documents = [
    {
      title:
        "Develop and Conduct a Water Resilience Tabletop Exercise with Water Utilities",
      description:
        "The Tabletop Exercise Tool for Drinking Water and Wastewater Utilities (TTX Tool) provides users with the resources to plan, conduct and evaluate tabletop exercises that focus on Water Sector-related incidents and challenges.",
      author: "United States Environmental Protection Agency",
      date: "2018, 2016",
      relevant_pages: "All",
      download_url:
        "https://dl.airtable.com/.attachments/bf4dd7ce96970e04591a1de8ec2ab251/d5c39c6e/final_2016_prep_guidelines.pdf",
      thumbnail_url: "",
      technical_area: "Chemical Events,Emergency Preparedness",
      reference_type: "Training Package",
    },
    {
      title: "WHO simulation exercise manual, guidance & tools",
      description:
        "This exercise manual has been designed to meet the needs of WHO, its Member States and its partners to support and develop exercise practitioners’ competency to plan, implement and evaluate simulation exercises. The manual complements existing WHO exercise methodologies, helping ensure common understandings\nand approaches across the organization. It describes how exercise teams work, and can supplement future training courses for WHO staff, ministries of health, governments, and preparedness and response partners.",
      author: "World Health Organization",
      date: "2017, 2018",
      relevant_pages: "All",
      download_url:
        "https://dl.airtable.com/.attachments/87ea5ee577cb686841c1558b46406ba4/e6448b04/WHO-WHE-CPI-2018_48-eng.pdf",
      thumbnail_url: "",
      technical_area:
        '"IHR Coordination, Communication and Advocacy, and Reporting",Zoonotic Disease,Food Safety,Immunization,National Laboratory System,Human Resources,Emergency Preparedness,Medical Countermeasures and Personnel Deployment',
      reference_type: "Guideline",
    },
  ]

  function documentList() {
    if (documents.length === 0) {
      return (
        <div className="row p-3">
          <div className="col font-italic">
            This action has no references. If you have a reference document for
            this indicator,{" "}
            <a href="https://airtable.com/shrGiWYwJV7TSJNMu">add it here</a>.
          </div>
        </div>
      )
    } else {
      return documents.map((document) => {
        return (
          <div className="row px-3 my-2" key={document.download_url}>
            <div className="col">
              <p className="font-weight-bold my-1">
                <a href={document.download_url}> {document.title} </a>
              </p>
              <p className="text-muted my-1">
                <span className="badge bg-secondary text-light p-2 mr-3">
                  {document.reference_type}
                </span>
                {document.author}, {document.date}.{" "}
                <span className="font-italic">Relevant pages: </span>
                {document.relevant_pages}.
              </p>
              <p className="mb-0">{document.description}</p>
            </div>
          </div>
        )
      })
    }
  }

  function actionDocumentDetail() {
    if (!expanded) {
      return
    }

    return (
      <>
        <div className="row px-2 justify-content-center">
          <div
            className="col bg-light-gray text-center py-1 mx-3"
            onClick={() => setExpanded(false)}
          >
            <img src={caret} alt="Collapse detail view" className="px-2" />
            collapse
          </div>
        </div>
        {documentList()}
      </>
    )
  }

  return (
    <div className="row action">
      <div className="col">
        <div className="row p-2" onClick={() => setExpanded(!expanded)}>
          <div className="col-10">
            <strong>{indicator.display_abbreviation}</strong>
            &nbsp;
            <span className="action-text">{action.text}</span>
          </div>
          <div className="col-1 d-flex flex-row align-items-center justify-content-end py-2 py-md-0 ">
            {action.level ? (
              <ActionBadge action={action} />
            ) : (
              <ActionBadgePill action={action} />
            )}
          </div>
          <div className="col-1 d-flex d-md-block py-2 py-md-0">
            <button
              className="delete close"
              type="button"
              onClick={() => dispatch(deleteAnAction(action.id, indicator.id))}
            >
              <img src="/delete-button.svg" alt="Delete this action" />
            </button>
          </div>
        </div>
        {actionDocumentDetail()}
      </div>
    </div>
  )
}

Action.propTypes = {
  action: PropTypes.object.isRequired,
}

export default Action
