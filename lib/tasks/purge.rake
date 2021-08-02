desc "Purge plans that are unassociated to a user and more than #{Plan::PURGEABLE_WEEKS} weeks old"
task purge: :environment do
  purgeable_plan_count = Plan.purgeable.count
  if purgeable_plan_count > 0
    warn "Purging #{purgeable_plan_count} plans..."
    Plan.purge_old_plans!
    warn "Purged #{purgeable_plan_count} plans."
  end
end
