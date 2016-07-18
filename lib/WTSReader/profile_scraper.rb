class WTSReader::Profile
  extend Helpers

  def self.any_matches?(url)
    methods.grep(/match\?/).map { |match_method| send(match_method, url)}.drop_while {|elem| elem != elem.to_s.to_sym}[0]
  end

  # guardian

  def self.guardian_match?(url)
    if url.match(/.+theguardian.com.+/i) || url.match(/.+theguardian.co.uk.+/i)
      return :get_guardian_text
    end
    false
  end
  def self.guardian_parse(doc)
    @headline = doc.css("h1.content__headline").text
    @blurb = doc.css("div.content__standfirst p").text
    @author = doc.css("p.byline").text
    @date = doc.css("p.content__dateline").text
    @content = doc.css("div.content__article-body p").text
  end
  def self.get_guardian_text(doc)
    guardian_parse(doc)
    "#{@headline}\n\nBy #{@author}\n\n#{@blurb}\nPublication date: #{@date}\n#{@content}".gsub('"', '\"')
  end
  def self.get_guardian_headlines
    doc = Nokogiri::HTML(open('https://www.theguardian.com/uk/technology'))
    headlines = doc.xpath('//*[@class="fc-item__container"]/a').map {|x| [x.text, x.values].flatten}
    # Returns an array of only headlines and urls. At time of writing (July 17), this works
    # on all Guardian section pages
    Helpers.process_headlines(headlines)
  end

  # stackoverflow

  def self.stackoverflow_parse(doc)
    doc.css(".everyonelovesstackoverflow").remove()
    doc.css("script").remove()
    @title = doc.css("h1 a.question-hyperlink").text
    @question = doc.css("div#mainbar div.question").text
    @accepted_answer = doc.css("div#mainbar div.accepted-answer").text
    @answers = doc.css("div#mainbar div#answers div.answer").text
  end
  def self.stackoverflow_match?(url)
    if url.match(/.+stackoverflow.com\/question.+/i)
      return :get_stackoverflow_text
    end
    false
  end
  def self.get_stackoverflow_text(doc)
    stackoverflow_parse(doc) 
    "#{@title}\n\nQuestion:\n#{@question}\n\n#{@accepted_answer}\n\n#{@answers}".gsub('"', '\"')
  end
end
