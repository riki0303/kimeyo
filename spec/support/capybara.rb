require 'capybara-playwright-driver'

Capybara.register_driver(:playwright_driver) do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium,
    headless: true
  )
end

Capybara.javascript_driver = :playwright_driver
Capybara.default_max_wait_time = 15
