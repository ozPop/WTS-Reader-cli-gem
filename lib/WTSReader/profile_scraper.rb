module WTSReader
  class Profile
    def self.any_matches?(url)
      methods.grep(/match\?/).map { |match_method| send(match_method, url)}.drop_while {|elem| elem != elem.to_s.to_sym}[0]
    end
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
    def self.stackoverflow_parse(doc)
      @title = doc.css("a.question-hyperlink").text
      @question = doc.css("div.question").text
      @accepted_answer = doc.css("div.accepted-answer").text
      @answers = doc.css("div.answer").text
    end
    def self.stackoverflow_match?(url)
      if url.match(/.+stackoverflow.com\/question.+/i)
	return :get_stackoverflow_text
      end
      false
    end
    def self.get_stackoverflow_text(doc)
      stackoverflow_parse(doc)
      "#{@title}\n\n#{@question}\n\nAccepted Answer: #{@accepted_answer}\n\n#{@answers}"
    end
  end
end
