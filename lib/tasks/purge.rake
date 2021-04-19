desc "Purge old and abandoned plans"
task :purge do
  purgeable_plans = Plan.purgeable

  return if purgeable_plans.empty?

  warn "Purging #{purgeable_plans.count} plans..."
  Plans.purge_old_plans!
  warn "Purged #{purgeable_plans.count} plans."
end
