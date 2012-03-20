module HelperMethods
  def click(locator)
    click_link_or_button(locator)
  end

  def mock_cartodb_oauth(attributes)
    OmniAuth.config.mock_auth[:cartodb] = OmniAuth::AuthHash.new(
      'info' => {
        'uid' => attributes[:uid] || rand(100),
        'username' => attributes[:username] || String.random(4)
      },
      'extra' => {
        'access_token' => {
          'token' => 'token',
          'secret' => 'secret'
        }
      }
    )
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance