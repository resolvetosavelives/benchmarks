import "./base"

const assessText =
  "<h3>Assess capacity</h3><p>Assessments such as JEE/SPAR to  identify and evaluate a country’s national preparedness capacities, identify risks and prioritize actions for capacity building to prevent, detect, and rapidly respond to public health and threats.</p>"

const planText =
  "<h3>Prioritize actions and convene for planning</h3><p>Identify and prioritize key benchmark activities based on JEE or SPAR assessment to guide and facilitate a convening and consensus-building process with cross-sectoral teams for a 1-year operational plan or 5-year NAPHS plan.</p>"

const costText =
  "<h3>Estimate costs</h3><p>Identify all available domestic and international resources (financial and technical) that are needed and estimate the costs to support decision making and prioritization.</p>"

const implementText =
  "<h3>Implement capacity building actions</h3><p>Use relevant guidance, tools, frameworks and other materials in the reference library that can inform the implementation of benchmark actions.</p>"

const monitorText =
  "<h3>Monitor and evaluate</h3><p>Continuously monitor and evaluate performance of national action plan.</p>"

$(() => {
  document
    .getElementById("assess-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = assessText
    })

  document.getElementById("plan-element").addEventListener("mouseenter", () => {
    document.getElementById("step-up-text").innerHTML = planText
  })

  document.getElementById("cost-element").addEventListener("mouseenter", () => {
    document.getElementById("step-up-text").innerHTML = costText
  })

  document
    .getElementById("implement-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = implementText
    })

  document
    .getElementById("monitor-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = monitorText
    })
})

// document.getElementById('cost-element').addEventListener('mouseenter',
//   function() {
//     document.getElementById('step-up-text')
//       .innerHTML = "<h5>Estimate costs</h5><p>Identify all available domestic and international resources (financial and technical) that are needed and estimate the costs to support decision making and prioritization.</p>"
//   }
// )
