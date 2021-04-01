class FinePayer
  attr_reader :token
  def initialize(uniqname:, fine_ids:, 
                 all_fines: Fines.for(uniqname: uniqname), 
                 nelnet_factory: lambda{|amountDue| Nelnet.new(amountDue: amountDue)},
                 jwt_encoder: lambda{|payload| JWT.encode payload, ENV.fetch('JWT_SECRET'), 'HS256'}
                )
    @fines = all_fines.select(fine_ids)
    @nelnet = nelnet_factory.call(amountDue) 
    @token = jwt_encoder.call(@fines.map{|x| x.to_h})
  end
  def orderNumber
    @nelnet.orderNumber
  end
  def url
    @nelnet.url
  end

  private
  def amountDue
    @fines.reduce(0) {|sum, f| sum + f.balance.to_f }.to_currency
  end
end
