class FFNScraper < Scraper
  def get_base_url
    @url.match(/(fictionpress\.com|fanfiction\.net)\/s\/\d+\//)
  end

  def get_story_title
    @page.at_css("#profile_top .xcontrast_txt").text.strip
  end

  def get_author
    @page.xpath("//a[starts-with(@href, '/u/')]").first.text.strip
  end

  def get_chapter_urls
    unless @page.css("#chap_select").empty?
      @page.at_css("#chap_select").css("option").map do |option|
        "https://www.#{@base_url}#{option['value']}/"
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
        title = option.text.strip
        break
      end
    end
    title
  end

  def get_chapters(chapter_urls, offset=0)
    chapter_urls.each_with_index do |chapter, index|
      @page = get_page(chapter) unless chapter == @page.uri
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + 1 + offset,
                     story_id: @story.id)
    end
  end

  def get_chapter_content
    @page.at_css("#storytext").to_s
  end

  def get_metadata_page
    get_page("https://www.#{@base_url}1/")
  end


end
