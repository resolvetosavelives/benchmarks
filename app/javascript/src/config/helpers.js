import { getDisease } from "./selectors"
import Dropdown from "react-bootstrap/Dropdown"
import React from "react"

const getColorForDiseaseId = (diseases, diseaseId) =>
  `color-value-disease-${getDisease(diseases, diseaseId).name}`

const makeDropdownItem = (label, index) => (
  <Dropdown.Item eventKey={index} key={`label-${index}`}>
    {label}
  </Dropdown.Item>
)

export { getColorForDiseaseId, makeDropdownItem }
