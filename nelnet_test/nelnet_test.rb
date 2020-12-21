require 'sinatra'
require "sinatra/reloader"
require "addressable"
require "digest"

get "/" do
  #"?orderNumber=1111.12345&orderType=UMLibraryCirc&orderDescription=U-M Library Circulation Fines&amountDue=1256&redirectUrl=http://mypatronacount.com/payment&redirectUrlParameters=transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber,orderType,orderDescription,payerFullName,actualPayerFullName,accountHolderName,streetOne,streetTwo,city,state,zip,country,email&retriesAllowed=1&timestamp=12345&hash=524e99bd77b1066b91364ff021c6827a3185e61e7c8d505cef6aef5741a8a65b"
 # params.to_s
  "Params value is #{verify(params)}"
  query = query(params["orderNumber"], params["amountDue"])
  full_query = append_hash(query)
  url = Addressable::URI.parse(params["redirectUrl"])
  url.query_values = full_query
  redirect url.normalize.to_s
end
def query(orderNumber,amountDue)
  {"transactionType"=>"1", "transactionStatus"=>"1", "transactionId"=>"382481568", "transactionTotalAmount"=>amountDue, "transactionDate"=>"202001211241", "transactionAcountType"=>"VISA", "transactionResultCode"=>"267849", "transactionResultMessage"=>"Approved and completed", "orderNumber"=>orderNumber, "orderType"=>"UMLibraryCirc", "orderDescription"=>"U-M Library Circulation Fines", "payerFullName"=>"Aardvark Jones", "actualPayerFullName"=>"Aardvark Jones", "accountHolderName"=>"Aardvark Jones", "streetOne"=>"555 S STATE ST", "streetTwo"=>"", "city"=>"Ann Arbor", "state"=>"MI", "zip"=>"48105", "country"=>"UNITED STATES", "email"=>"Qinyangz@umich.edu", "timestamp"=>"1579628471900" }
end
def verify(params)
    hash = params.delete('hash')
    string = CGI.unescape(params.values.join('') + ENV.fetch('NELNET_SECRET_KEY'))
    hash == (Digest::SHA256.hexdigest string)
end
def append_hash(request_params)
  my_params = request_params.values.join('')
  my_params = my_params + ENV.fetch('NELNET_SECRET_KEY')
  hash = Digest::SHA256.hexdigest my_params
  request_params.to_a.push(["hash",hash])
end
