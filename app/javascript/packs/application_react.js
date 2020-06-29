// TODO: why is this needed for tooltip() boostrap's jquery plugin to not fail with an error? why jquery not even needed to be imported here? is this duplicated between packs? are others duplicated?
import "bootstrap"

var componentRequireContext = require.context("src/components", true)
var ReactRailsUJS = require("react_ujs")
// eslint-disable-next-line react-hooks/rules-of-hooks
ReactRailsUJS.useContext(componentRequireContext)
