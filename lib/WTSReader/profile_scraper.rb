class Profile
  extend Helpers::ClassMethods
  attr_accessor :doc, :url
  def initialize(doc=nil, url=nil)
    @doc = doc
    @url = url
  end

  def self.get_guardian_headlines
    doc = Nokogiri::HTML(open('https://www.theguardian.com/uk/technology'))
    headlines = doc.xpath('//*[@class="fc-item__container"]/a').map {|x| [x.text, x.values].flatten}
    # Returns an array of only headlines and urls. At time of writing (July 17), this works
    # on all Guardian section pages
    self.process_headlines(headlines)
  end

  def any_matches?
    self.methods.grep(/match\?/).map { |match_method| self.send(match_method)}.drop_while {|elem| elem != elem.to_s.to_sym}[0]
  end

  # guardian
  def guardian_tech_url
    'https://www.theguardian.com/uk/technology'
  end

  def guardian_match?
    if @url.match(/.+theguardian.com.+/i)
      return :get_guardian_text
    end
    false
  end
  def guardian_parse
    @headline = @doc.css("h1.content__headline").text
    @blurb = @doc.css("div.content__standfirst p").text
    @author = @doc.css("p.byline").text
    @date = @doc.css("p.content__dateline").text
    @content = @doc.css("div.content__article-body p").text
  end
  def get_guardian_text
    guardian_parse
    "#{@headline}\n\nBy #{@author}\n\n#{@blurb}\nPublication date: #{@date}\n#{@content}".gsub('"', '\"')
  end

  # learn

  def learn_match?
    if @url.match(/.+learn.co.+/i) || @url.match(/.+learn.co.+/i)
      return :get_learn_text
    end
    false
  end
  def learn_parse
    @headline = @doc.css("h2 strong").text
    @content = @doc.css("div.text-block").text
  end
  def get_learn_text
    learn_parse
    "#{@headline}\n\n#{@content}".gsub('"', '\"').gsub("\n", "\n\n")
  end

  # stackoverflow

  def stackoverflow_parse
    @doc.css(".everyonelovesstackoverflow").remove()
    @doc.css("script").remove()
    @title = @doc.css("h1 a.question-hyperlink").text
    @question = @doc.css("div#mainbar div.question").text
    @accepted_answer = @doc.css("div#mainbar div.accepted-answer").text
    @answers = @doc.css("div#mainbar div#answers div.answer").text
  end
  def stackoverflow_match?
    if @url.match(/.+stackoverflow.com\/question.+/i)
      return :get_stackoverflow_text
    end
    false
  end
  def get_stackoverflow_text
    stackoverflow_parse 
    "#{@title}\n\nQuestion:\n#{@question}\n\n#{@accepted_answer}\n\n#{@answers}".gsub('"', '\"')
  end
end
