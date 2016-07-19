module Helpers
  # TODO: rename this module to something more relevant
  
  module ClassMethods
    def process_headlines(headlines_with_url)
      output_hash = {}
      headlines_with_url.each_with_index do |data, index|
        output_hash[index+1] = [data[0], data[1]]
      end
      output_hash
    end
  end # end ClassMethods

  module InstanceMethods
    # takes in a hash and array. returns array with all hash internals
    # itterates (recursive) pusing all keys and values to given array
    def hash_to_array(hash, array)
      hash.each do |key, value|
        if value.class == Hash
          array << key.to_s
          hash_to_array(value, array)
        else
          array << key.to_s
          array << value
        end
      end
      array.flatten
    end
  end # end InstanceMethods

end