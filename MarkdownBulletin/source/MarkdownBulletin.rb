# read text from shell
s = $stdin.read

# remove trailing non-breaking space added automatically by IPBoard
s = s.gsub / +$/, ''

# bypass empty line collapsing done by IPBoard
s = s.gsub /^$/, "\n"

# horizontal rule
s = s.gsub /^(- *|\* *){3,}$/, '[hr]'

# image that sends to url
s = s.gsub /\[!\[[^\]]*\]\(([^)]*)\)\]\(([^)]*)\)/, '[url=\2][img=\1][/url]'

# image
s = s.gsub /!\[[^\]]*\]\(([^)]*)\)/, '[img=\1]'

# url
s = s.gsub /\[([^\]]*)\]\(([^)]*)\)/, '[url=\2]\1[/url]'

# bold and italic
s = s.gsub /\*\*\*(\S.*?)\*\*\*/, '[b][i]\1[/i][/b]'

# bold
s = s.gsub /\*\*(\S.*?)\*\*/, '[b]\1[/b]'

# italic
s = s.gsub /\*(\S.*?)\*/, '[i]\1[/i]'

# strike through
s = s.gsub /~~(.*)~~/, '[s]\1[/s]'

# quote
s = s.gsub /^>\s(.*)/, '[quote]\1[/quote]'

# code block
## with backticks
s = s.gsub /^\n^```(.*?)```/m, '[code]\1[/code]'

## with spacing or tabs
s = s.gsub /^\n(^ {4}|\t)/, "\n[code=auto:0]\n\\1" # beginning
s = s.gsub /\A(^ {4}|\t)/, "[code=auto:0]\n\\1" # if beginning of text
s = s.gsub /^(( {4}|\t).*)\n\n/, "\\1\n[/code]\n\n" # end
s = s.gsub /^(( {4}|\t).*)$\z/, "\\1\n[/code]" # if end of text
s = s.gsub /(^ {4}|\t)/, '' # middle

# inline code
s = s.gsub /`(.*?)`/, '[background=#eee][font=courier,monospace]\1[/font][/background]'

# headers
s = s.gsub /^#\s(.*?)[ #]*$/, '[size=7][b]\1[/b][/size]' # big
s = s.gsub /^##\s(.*?)[ #]*$/, '[size=6][b]\1[/b][/size]' # medium
s = s.gsub /^###\s(.*?)[ #]*$/, '[size=5][b]\1[/b][/size]' # small

# lists
## unordered
s = s.gsub /^\n^([*+-]\s)/, "[list]\n\\1" # beginning
s = s.gsub /\A^([*+-]\s)/, "[list]\n\\1" # if beginning of text
s = s.gsub /^([*+-]\s.*)\n\n/, "\\1\n[/list]\n" # end
s = s.gsub /^([*+-]\s.*)\z/, "\\1\n[/list]" # if end of text
s = s.gsub /^[*+-]\s(.*)/, '[*]\1[/*]' # middle

## ordered
s = s.gsub /^\n^(\d\.\s)/, "[list=1]\n\\1" # beginning
s = s.gsub /\A^(\d\.\s)/, "[list=1]\n\\1" # if beginning of text
s = s.gsub /^(\d\.\s.*)\n\n/, "\\1\n[/list]\n" # end
s = s.gsub /^(\d\.\s.*)\z/, "\\1\n[/list]" # if end of text
s = s.gsub /^\d\.\s(.*)/, '[*]\1[/*]' # middle

# footnotes
s = s.gsub /^\n{2}(\[\^\d+\])/, "\n\n[hr]\n\\1" # division before references
s = s.gsub /^\[\^(\d+)\]:\s*(.*)/, "\n[size=3]\\1. \\2[/size]" # style references and space them
s = s.gsub /\[\^(.*?)\]/, '[sup]\1[/sup]' # footnotes in text

print s
