module CCBill
  class DynamicPricingError < StandardError; end

  class DynamicPricing
    attr_accessor :variables, :config, :errors

    def initialize(options = {})
      self.config = CCBill.configuration

      fail_on_price_set(options)

      modified_options = modify_params(options)

      self.variables = {
        account:        config.account,
        sub_account:    config.sub_account,
        currency_code:  config.default_currency
      }.merge(modified_options)
    end

    def url
      raise DynamicPricingError.new(self.errors.join(' ')) if !valid?

      variables[:form_digest] = encode_form_digest

      config.endpoint + config.flexform_id + '?' + URI.encode_www_form(transformed_variables)
    end

    def valid?
      self.errors = []

      required_fields.each do |field|
        self.errors << "#{field} is required." if !variables[field]
      end

      unless (config.min_price.to_f..config.max_price.to_f).include?(variables[:initial_price].to_f)
        self.errors << "Initial price must be between $#{config.min_price} and $#{config.max_price}."
      end

      if recurring?
        unless (config.min_price.to_f..config.max_price.to_f).include?(variables[:recurring_price].to_f)
          self.errors << "Recurring price must be between $#{config.min_price} and $#{config.max_price}."
        end
      end

      self.errors.empty?
    end

    private

    def encode_form_digest
      hashed_fields = if recurring?
        [
          variables[:initial_price],
          variables[:initial_period],
          variables[:recurring_price],
          variables[:recurring_period],
          variables[:num_rebills],
          variables[:currency_code],
          config.salt
        ]
      else
        [
          variables[:initial_price],
          variables[:initial_period],
          variables[:currency_code],
          config.salt
        ]
      end

      Digest::MD5.hexdigest(hashed_fields.join)
    end

    def recurring?
      variables[:recurring_price] || variables[:recurring_period] || variables[:num_rebills]
    end

    def required_fields
      req = [
        :initial_price,
        :initial_period
      ]

      if recurring?
        req += [
          :recurring_price,
          :recurring_period,
          :num_rebills
        ]
      end

      req
    end

    def ccbill_field(internal)
      {
        account:          'clientAccnum',
        sub_account:      'clientSubacc',
        initial_price:    'initialPrice',
        initial_period:   'initialPeriod',
        currency_code:    'currencyCode',
        recurring_price:  'recurringPrice',
        recurring_period: 'recurringPeriod',
        num_rebills:      'numRebills',
        form_digest:      'formDigest'
      }[internal] || internal
    end

    def transformed_variables
      transform_keys(variables) { |key| ccbill_field(key) }
    end

    # From Active Support:
    def transform_keys(_hash)
      result = {}
      _hash.keys.each do |key|
        result[yield(key)] = _hash[key]
      end
      result
    end


    def modify_params(options)
      initial_cents = options.delete(:initial_price_in_cents)
      options[:initial_price] = convert_to_price(initial_cents) if initial_cents

      recurring_cents = options.delete(:recurring_price_in_cents)
      options[:recurring_price] = convert_to_price(recurring_cents) if recurring_cents

      options
    end

    def convert_to_price(cents)
      '%.2f' % (cents / 100.to_f)
    end

    def fail_on_price_set(options)
      compared_array = [:initial_price, :recurring_price] & options.keys
      if compared_array.any?
        array_with_cents = compared_array.map{|word| word.to_s + '_in_cents' }.join(', ')

        fail SyntaxError, "You misspelled! Gem uses #{array_with_cents} value(s)."
      end
    end
  end
end
