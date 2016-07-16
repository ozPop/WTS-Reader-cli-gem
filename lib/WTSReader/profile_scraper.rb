module WTSReader
  class Profiles
    def match?
    end
    def guardian_profile(doc)
      headline = doc.css("h1.content__headline")
      blurb = doc.css("div.content__standfirst p")
      author = doc.css("p.byline")
      date = doc.css("p.content__dateline")
      content = doc.css("div.content__article-body p")
    end
  end
end
