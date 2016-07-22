class FFNScraper < Scraper

  def get_base_url
    @url.match(/fanfiction\.net\/s\/\d+\//)
  end

  def update_story
    puts "UPDATE"
  end

  def get_story_title
    @page.at_css("#profile_top .xcontrast_txt").text
  end

  def get_author
    @page.xpath("//a[starts-with(@href, '/u/')]").first.text
  end

  def get_chapter_urls
    puts "IN GET_CHAP_URLS"

    unless @page.css("#chap_select").empty?
      @page.at_css("#chap_select").css("option").map do |option|
        "#{@base_url}#{option['value']}/"
      end
    else
      [@page.uri]
    end
  end

  def get_chapter_title
    options = @page.css('#chap_select option')
    title = ""
    options.each do |option|
      if option['selected']
        title = option.text
        break
      end
    end
    title
  end

  def get_chapter_content
    @page.at_css("#storytext").to_s
  end

  def get_metadata_page
    @agent.get("https://www.#{@base_url}1/")
  end


end
