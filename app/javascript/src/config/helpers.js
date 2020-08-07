import { getDisease } from "./selectors"

const getColorForDiseaseId = (diseases, diseaseId) =>
  `color-value-disease-${getDisease(diseases, diseaseId).name}`

export { getColorForDiseaseId }
