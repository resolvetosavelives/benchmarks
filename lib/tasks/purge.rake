desc "Purge old and abandoned plans"
task purge: :environment do
  purgeable_plans = Plan.purgeable
  if purgeable_plans.any?
    warn "Purging #{purgeable_plans.count} plans..."
    Plans.purge_old_plans!
    warn "Purged #{purgeable_plans.count} plans."
  end
end
