require "capybara/cuprite"
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
#Capybara.default_driver = :cuprite

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 1200],
    browser_options: {},
    # Increase Chrome startup wait time (required for stable CI builds)
    process_timeout: 60,
    # Tell Ferrum to wait longer for browsers to respond, helps on slow machines like CI
    # Azure seems to be much slower.
    timeout: 30,
    # Enable debugging only outside CI by default
    inspector: ENV["CI"].nil? || ENV["INSPECTOR"],
    # Allow running Chrome in a headful mode by setting HEADLESS env
    # var to a falsey value
    headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
  )
end

module CupriteHelpers
  # Drop #pause anywhere in a test to stop the execution.
  # Useful when you want to checkout the contents of a web page in the middle of a test
  # running in a headful mode.
  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the execution
  def debug(*args)
    page.driver.debug(*args)
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system

  config.before(:each, type: :system, js: true) do
    driven_by :cuprite,
              using: :chrome,
              screen_size: [1400, 1400],
              options: {
                inspector: ENV["INSPECTOR"].present?,
                headless: ENV["INSPECTOR"].blank?
              }
  end
end
