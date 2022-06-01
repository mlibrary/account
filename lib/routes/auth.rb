use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: "https://weblogin.lib.umich.edu",
    discovery: true,
    client_auth_method: "jwks",
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV["WEBLOGIN_ID"],
      secret: ENV["WEBLOGIN_SECRET"],
      redirect_uri: "#{ENV["PATRON_ACCOUNT_BASE_URL"]}/auth/openid_connect/callback"
    }
  }
end

get "/auth/openid_connect/callback" do
  auth = request.env["omniauth.auth"]
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  patron = SessionPatron.new(info[:nickname])
  patron.to_h.each { |k, v| session[k] = v }
  redirect session.delete(:path_before_login) || "/"
end

get "/auth/failure" do
  "You are not authorized"
end

get "/logout" do
  session.clear
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"
end

get "/login" do
  erb :"login/index", locals: {has_js: true}
end
