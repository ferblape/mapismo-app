require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class CartoDb < OmniAuth::Strategies::OAuth
      uid do
        request.params['user_id']
      end

      info do
        {
          :email => raw_info['email'],
          :username => raw_info['username'],
          :uid => raw_info['uid']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/oauth/identity').body)
      end
    end
  end
end