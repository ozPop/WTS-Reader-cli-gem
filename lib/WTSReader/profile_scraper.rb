module WTSReader
  class Profiles
    def match?(url)
      if url.match(/theguardian.com/) || url.match(/theguardian.co.uk/)
	get_guardian_text(
      end
    end
    def guardian_parse(doc)
      @headline = doc.css("h1.content__headline").text
      @blurb = doc.css("div.content__standfirst p").text
      @author = doc.css("p.byline").text
      @date = doc.css("p.content__dateline").text
      @content = doc.css("div.content__article-body p").text
    end
    def get_guardian_text(doc)
      guardian_parse(doc)
      "#{@headline}\n\nBy #{@author}\n\n#{@blurb}\nPublication date: #{@date}\n#{@content}"
    end
  end
end
