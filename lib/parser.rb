def update_parser
bitcoin = []

url = 'https://www.99cryptocoin.com/ru/?gclid=CjwKCAiAtorUBRBnEiwAfcp_Y6YwRiYWPj_JLiYyB7dCVKgz1aYV7vSrsmREh7dKLkdVuBu5qhG7XBoCjVcQAvD_BwE'
html = open(url)
doc = Nokogiri::HTML(html)

doc.css('tr').each do |line|
	n = line['data-href'].to_s.split('/').last
	pr = line.css('.js-format-price').text
	bitcoin.push(
	name: n,
	price: pr
	)
end
bitcoin.shift
File.write('storage/reviews.json', JSON.pretty_generate(bitcoin))
end
def get_parser
  file = File.read('storage/reviews.json')
  @movie.parse = JSON.parse(file)
end
