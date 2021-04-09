require 'httparty'

class CircHistoryClient
  include HTTParty
  base_uri "#{ENV.fetch('CIRCULATION_HISTORY_URL')}/v1"

  def initialize(uniqname)
    self.class.headers 'Accept' => 'application/json'
    @uniqname = uniqname
  end

  def user_info
    self.class.get("/users/#{@uniqname}")
  end

  def loans(query={})
    self.class.get("/users/#{@uniqname}/loans", query: query)
  end

  #def download_csv
    #self.class.get("/users/#{@uniqname}/loans/download.csv")
  #end

  def set_retain_history(retain_history)
    self.class.put("users/#{@uniqname}", query: {retain_history: retain_history})
  end
  
end
