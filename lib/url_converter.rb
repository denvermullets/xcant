module UrlConverter
  TWITTER_URL_REGEX = %r{https?://(?:www\.)?(?:twitter\.com|x\.com)/[^\s<>]+}i

  def self.extract_and_convert(text)
    urls = text.scan(TWITTER_URL_REGEX)
    return nil if urls.empty?

    urls.map { |url| convert(url) }.uniq
  end

  def self.convert(url)
    url.gsub(%r{https?://(?:www\.)?(?:twitter\.com|x\.com)}, 'https://xcancel.com')
  end
end
