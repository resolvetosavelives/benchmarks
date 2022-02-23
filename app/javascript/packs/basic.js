import "./base"
import "particles.js"

const assessText =
  "<h3>Assess capacity</h3>" +
  "<p>Countries must assess their ability to prevent, detect and respond to epidemics using different approaches that provide unique insights into the country’s risk, vulnerability and capacity profile for health emergency threats.</p>"

const developText =
  "<h3>Prioritize actions for health security preparedness strengthening</h3>" +
  "<p>Generate priority actions for a 5-year strategic plan or a 1-year operational plan using the WHO Benchmarks digital tool, convene key actors to build political will across sectors and identify the resources necessary for systems change to support planning and resource allocation for national plans.</p>"

const implementText =
  "<h3>Implement prioritized actions</h3>" +
  "<p>Use relevant best practices, guidelines, tools, and training packages to support the implementation of prioritized actions. As you implement your plan, continuously monitor and evaluate performance.</p>"

$(() => {
  document
    .getElementById("assess-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = assessText
    })

  document
    .getElementById("develop-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = developText
    })

  document
    .getElementById("implement-element")
    .addEventListener("mouseenter", () => {
      document.getElementById("step-up-text").innerHTML = implementText
    })

  particlesJS.load("particles-js", "/particles.json") //eslint-disable-line
})
