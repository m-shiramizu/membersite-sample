class HomeController < ApplicationController

  def index
  end

  # ユーザー情報取得
  def show
    token = session[:access_token]
    client = doorkeeper_oauth_client(nil,nil,ENV['DOORKEEPER_APP_PROVIDER_URL'])
    accesstoken = OAuth2::AccessToken.new(client,token)
    @userinfo = accesstoken.get('/api/v1/me.json').parsed
  end

  # 他の画面に遷移
  def move
     # 移動先画面用の認可コード取得
    code = doorkeeper_get_authrization_code(
          ENV['DOORKEEPER_APP_ID_DUMMY'], 
          ENV['DOORKEEPER_APP_SECRET_DUMMY'], 
          ENV['DOORKEEPER_APP_PROVIDER_URL'], 
          ENV['DOORKEEPER_REDIRECT_DUMMY_URI'])
    redirect_to code
  end

  # ログアウト
  def destroy
    # アクセストークンの削除
    path = ENV['DOORKEEPER_APP_PROVIDER_URL'] + '/oauth' + '/revoke'
    uri = URI.parse(path)
    Net::HTTP.start(uri.host, uri.port){|http|
      header = {
        "Authorization" => "Bearer #{session[:access_token]}"
      }
      body = "token=#{session[:access_token]}"
      response = http.post(uri.path, body, header)
    }
 
    reset_session
    redirect_uri = ENV['DOORKEEPER_APP_PROVIDER_URL'] + 'users/sign_out'
    redirect_to redirect_uri
  end

end
