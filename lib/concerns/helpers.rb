module Helpers
  # TODO: rename this module to something more relevant
  def self.process_headlines(headlines_with_url)
    output_hash = {}
    headlines_with_url.each_with_index do |data, index|
      output_hash[index+1] = [data[0], data[1]]
    end
    output_hash
  end
end