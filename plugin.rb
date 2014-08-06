# name: existing_site_oauth2
# about: Authenticate with discourse via ExistingSite's Oauth
# version: 0.2.0
# authors: Michael Kirk

require 'auth/oauth2_authenticator'

class ExistingSiteAuthenticator < ::Auth::OAuth2Authenticator

  CLIENT_ID = GlobalSetting.lb_oauth_client_id
  CLIENT_SECRET = GlobalSetting.lb_oauth_client_secret

  def register_middleware(omniauth)
    omniauth.provider :littlebits_oauth,
      CLIENT_ID,
      CLIENT_SECRET
  end
end

require 'omniauth-oauth2'
class OmniAuth::Strategies::LittlebitsOauth < OmniAuth::Strategies::OAuth2

  # NOTE VM has to be able to resolve
  SITE_URL = GlobalSetting.lb_oauth_site_url

  # Give your strategy a name.
  option :name, "littlebits_oauth"

  # This is where you pass the options you would pass when
  # initializing your consumer from the OAuth gem.
  option :client_options, site: SITE_URL

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.
  uid{ raw_info['user']['id'].to_s }

  info do
    {
      :email => raw_info['user']['email'],
      :name => raw_info['user']['username']
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    @raw_info ||= access_token.get('/api/v1/me.json').parsed
  end
end

auth_provider :title => 'littleBits',
    :message => 'Log in via the main site (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => ExistingSiteAuthenticator.new('littlebits_oauth', trusted: true)

register_css <<CSS

.btn-social.littlebits_oauth {
  background: #5e027e;
}

CSS
