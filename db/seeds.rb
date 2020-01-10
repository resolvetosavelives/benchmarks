##
# Use a transaction here in case any step fails it can be re-run in its entirety.
# It helps in case there is partial failure but some step(s) have succeed and
# then you would have to clean it up by hand.
#ActiveRecord::Base.connection.transaction do
  ApplicationRecord::SEEDABLE_MODELS.map(&:constantize).each(&:seed!)
#end
