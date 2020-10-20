require 'json'
class Response
  def initialize(status: 200, body:) 
    @status = status
    @body = body
    @headers = {"Content-Type" => "application/json"}
  end
  def to_a
    [@status, @headers, @body.to_json]
  end
end
