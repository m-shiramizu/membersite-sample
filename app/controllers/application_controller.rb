class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # ログインしていないとアクセスできない
  before_action :login_required
  
  # OAuthクライアント作成
  def doorkeeper_oauth_client(app_id, app_secret, app_url)
    @client ||= OAuth2::Client.new(app_id, app_secret, :site => app_url)
   end

  # AccessToken作成
  def doorkeeper_access_token
    @token ||= OAuth2::AccessToken.new(doorkeeper_oauth_client, current_user.doorkeeper_access_token) 
  end

  # 認可コード取得
  def doorkeeper_get_authrization_code(app_id, app_secret, app_url,uri)
    client = doorkeeper_oauth_client(app_id, app_secret, app_url)
    authorize_url = client.auth_code.authorize_url(:redirect_uri => uri)
  end

  private
    # ログイン状態をチェック
    def login_required
        # 認可コード取得必要
        if session[:access_token].blank?
          # 認可コードがあればアクセストークン取得
          if params[:code].present?
            get_accesstoken
          else
             # 認可コード取得
             code = doorkeeper_get_authrization_code(
               ENV['DOORKEEPER_APP_ID'], ENV['DOORKEEPER_APP_SECRET'], 
               ENV['DOORKEEPER_APP_PROVIDER_URL'],ENV['DOORKEEPER_REDIRECT_URI'])
             redirect_to code
          end
        end
   end

   # アクセストークン取得
   def get_accesstoken
     # アクセストークン取得
     client = doorkeeper_oauth_client(
          ENV['DOORKEEPER_APP_ID'],ENV['DOORKEEPER_APP_SECRET'],
          ENV['DOORKEEPER_APP_PROVIDER_URL'])
     token = client.auth_code.get_token(
                params[:code], 
                redirect_uri:  ENV['DOORKEEPER_REDIRECT_URI'], 
               headers: {'Authorization' => 'Basic some_password'})
     # アクセストークンをセッションに保存
     session[:access_token] = token.token
     # top 画面に遷移
     redirect_to controller: :home, action: :index
   end

end
