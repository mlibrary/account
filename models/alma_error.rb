class AlmaError
  def initialize(response)
    @response = response
  end
  def response(resp = Response.new(status: @response.code, body: @response.parsed_response))
    resp.to_a
  end
end
