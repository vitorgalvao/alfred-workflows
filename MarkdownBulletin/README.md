Markdown to BBCode syntax conversion.

The conversions it supports (I can add more via request) are
+ Bold → **example**
+ Italic → *example*
+ Bold and italic → ***example***
+ Horizontal rule → --- or - - - or *** or * * * with as many - or * as you’d like, as long as they’re at least three
+ Strike through → ~~example~~
+ Images that send to an external URL → [![](link_to_image)](link_to_website)
+ Images → ![](link_to_image)
+ URLs → [description](link_to_website)
+ Quotes → start lines with > and a space
+ Code blocks → ``` on one line, write code, ``` on another line to end or indent lines with either fours spaces or a tab
Inline code → with a ` at the start and another at the end, by default it’ll convert the text to use a monospaced font and a grey background
+ Differently sized headers → start lines with # or ## or ###, and a space. End them with any number (including none) of spaces and # characters
+ Unordered lists → precede items with + or * or -, and a space
+ Ordered lists → precede items with a number, a period, and a space
+ Footnotes → [^1] (where “1” is any number) anywhere in your text, and again at the end as [^1]: with the footnote’s text
+ Changes that span multiple lines (code blocks and lists) should be preceded and followed by empty lines (except it they’re at the beginning or end of your text, in which case the extra empty line at the top or bottom, respectively, is not needed).

All the code is in the script inside the workflow — it’s one line per substitution and they’re all commented so you shouldn’t have much trouble changing anything you’d like to be handled a different way, even if you don’t understand regular expressions (you’ll mostly need to care about what’s on the right side of the commas).
