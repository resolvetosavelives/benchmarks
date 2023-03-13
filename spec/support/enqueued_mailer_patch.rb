# This patches rspec-rails to support rails 7.0. Once we upgrade rspec-rails to
# 6.0.0 we can remove this file.
# Otherwise, we get the following error when we use expect { ... }.to have_enqueued_email(...)
# NameError: uninitialized constant ActionMailer::DeliveryJob
# https://github.com/rspec/rspec-rails/issues/2531#issuecomment-972836152
class RSpec::Rails::Matchers::HaveEnqueuedMail
  def legacy_mail?(job)
    defined?(ActionMailer::DeliveryJob) &&
      job[:job] <= ActionMailer::DeliveryJob
  end

  def parameterized_mail?(job)
    RSpec::Rails::FeatureCheck.has_action_mailer_parameterized? &&
      job[:job] <= ActionMailer::MailDeliveryJob
  end

  def unified_mail?(job)
    RSpec::Rails::FeatureCheck.has_action_mailer_unified_delivery? &&
      job[:job] <= ActionMailer::MailDeliveryJob
  end
end
