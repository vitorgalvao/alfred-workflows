require 'redcarpet'

class IPBoardBBCodeRender < Redcarpet::Render::Base
  # Needed since we are inheriting from the base render, which doesn't implement any method by default
  def paragraph(text)
    "\n\n" + text
  end

  def emphasis(text)
    surround(text, :i)
  end

  def double_emphasis(text)
    surround(text, :b)
  end

  def triple_emphasis(text)
    surround(surround(text, :b), :i)
  end

  def strikethrough(text)
    surround(text, :s)
  end

  def underline(text)
    surround(text, :u)
  end

  def image(link, title, alt_text)
    surround(link, :img)
  end

  def link(link, title, content)
    surround(content, :url, link)
  end

  def list(contents, list_type)
    case list_type
    when :ordered
      surround(contents, :list, '1')
    else
      surround(contents, :list)
    end
  end

  def list_item(text, list_type)
    '[*]' + text.strip
  end

  def header(text, level)
    header_size =
      case level
      when 1
        '7'
      when 2
        '6'
      when 3
        '5'
      else
        '4'
      end

    "\n\n" + surround(surround(text, :b), :size, header_size)
  end

  def block_quote(text)
    "\n\n" + surround(text.strip, :quote)
  end

  def superscript(text)
    surround(text, :sup)
  end

  def hrule
    "\n\n[hr]"
  end

  def codespan(code)
    surround(surround(code, :font, 'courier,monospace'), :background, '#eee')
  end

  def block_code(code, language)
    '[code]' + code.strip + '[/code]'
  end

  def footnotes(content)
    "\n\n[hr]" + content
  end

  def footnote_ref(number)
    surround(number, :sup)
  end

  def footnote_def(content, number)
    surround(number.to_s + '. ' + content.strip, :size, '3') + "\n"
  end

  private

  def surround(text, tag, extra_attr = nil)
    extra_attr = '=' + extra_attr if extra_attr
    params = {
      tag: tag,
      text: text,
      extra_attr: extra_attr || ''
    }

    format('[%<tag>s%<extra_attr>s]%<text>s[/%<tag>s]', params)
  end
end
