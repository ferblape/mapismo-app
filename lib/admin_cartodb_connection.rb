# coding: UTF-8

module MapismoApp
  class AdminCartoDBConnection < CartoDBConnection
    def initialize
      super(OAuth::AccessToken.new(load_consumer, Mapismo.oauth_token, Mapismo.oauth_secret))
    end
  end
end