# fix needed in Alfred (see http://www.alfredforum.com/topic/3173-ruby-workflows-in-mavericks/page-2#entry19605)
Encoding::default_external = Encoding::UTF_8 if defined? Encoding

# read text from shell
s = $stdin.read

# bold
s = s.gsub /\*\*(.*?)\*\*/, '[b]\1[/b]'

# italic
s = s.gsub /\*(.*?)\*/, '[i]\1[/i]'

# horizontal rule
s = s.gsub /^[- \*]{3,}$/, '[hr]'

# image
s = s.gsub /!\[\]\((.*?)\)/, '[img]\1[/url]'

# url
s = s.gsub /\[(.*?)\]\((.*?)\)/, '[url=\2]\1[/url]'

# code block
## with backticks
s = s.gsub /```(.*?)```/m, '[code=auto:0]\1[/code]'

## with spacing or tabs
s = s.gsub /^\n(^ {4}|\t)/, "\n[code=auto:0]\n\\1" # beginning
s = s.gsub /^(( {4}|\t).*)\n\n/, "\\1\n[/code]\n\n" # end
s = s.gsub /^(( {4}|\t).*)$\z/, "\\1\n[/code]" # if end of text
s = s.gsub /(^ {4}|\t)/, '' # middle

# inline code
s = s.gsub /`(.*?)`/, '[u][b]\1[/b][/u]'

# lists
## unordered
s = s.gsub /^\n^([*+-])/, "\n[list]\n\\1" # beginning
s = s.gsub /^([*+-].*)\n\n/, "\\1\n[/list]\n\n" # end
s = s.gsub /^([*+-].*)\z/, "\\1\n[/list]" # if end of text
s = s.gsub /^[*+-]\s*(.*)/, '[*]\1[/*]' # middle

## ordered
s = s.gsub /^\n^(\d\.)/, "\n[list=1]\n\\1" # beginning
s = s.gsub /^(\d\..*)\n\n/, "\\1\n[/list]\n\n" # end
s = s.gsub /^(\d\..*)\z/, "\\1\n[/list]" # if end of text
s = s.gsub /^\d\.\s*(.*)/, '[*]\1[/*]' # middle

print s