CCBill.configure do |config|
  config.mode = :test
  config.salt = 'Encryption Key'
  config.default_currency = '840' # USD
  config.account = 'account_id'
  config.sub_account = '0000'
  config.flexform_id = 'flexform_id'
  config.min_price = '2.95'
  config.max_price = '100'
end
