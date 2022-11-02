defmodule Conversion.Content.Writers.XML do
  alias Conversion.Content.Writers.Writer
  alias Conversion.Content.Writers.Context

  @behaviour Writer

  def p(%Context{} = _context, next, _) do
    ["<p>", next.(), "</p>\n"]
  end

  def table(%Context{} = _context, next, _) do
    ["<table>", next.(), "</table>\n"]
  end

  def caption(%Context{} = _context, next, _) do
    ["<caption>", next.(), "</caption>\n"]
  end

  def thead(%Context{} = _context, next, _) do
    next.()
  end

  def tbody(%Context{} = _context, next, _) do
    next.()
  end

  def tfoot(%Context{} = _context, next, _) do
    next.()
  end

  def tr(%Context{} = _context, next, _) do
    ["<tr>", next.(), "</tr>\n"]
  end

  def td(%Context{} = _context, next, _) do
    ["<td>", next.(), "</td>\n"]
  end

  def th(%Context{} = _context, next, _) do
    ["<th>", next.(), "</th>\n"]
  end

  def image(%Context{} = _context, _, %{data: %{"src" => src}}) do
    ["<image src=\"", escape_xml(src), "\"/>\n"]
  end

  def youtube(%Context{} = _context, _, %{data: %{"src" => src}}) do
    ["<youtube src=\"", src, "\"/>\n"]
  end

  def ul(%Context{} = _context, next, _) do
    ["<ul>", next.(), "</ul>\n"]
  end

  def ol(%Context{} = _context, next, _) do
    ["<ol>", next.(), "</ol>\n"]
  end

  def dl(%Context{} = _context, next, _) do
    ["<dl>", next.(), "</dl>\n"]
  end

  def dt(%Context{} = _context, next, _) do
    ["<dt>", next.(), "</dt>\n"]
  end

  def dd(%Context{} = _context, next, _) do
    ["<dd>", next.(), "</dd>\n"]
  end

  def li(%Context{} = _context, next, _) do
    ["<li>", next.(), "</li>\n"]
  end

  def header(%Context{} = _context, next) do
    ["<section><title>", next.(), "</title><body><p></p></body></section>\n"]
  end

  def h1(%Context{} = context, next, _) do
    header(context, next)
  end

  def h2(%Context{} = context, next, _) do
    header(context, next)
  end

  def h3(%Context{} = context, next, _) do
    header(context, next)
  end

  def h4(%Context{} = context, next, _) do
    header(context, next)
  end

  def h5(%Context{} = context, next, _) do
    header(context, next)
  end

  def h6(%Context{} = context, next, _) do
    header(context, next)
  end

  def audio(%Context{} = _context, _, %{data: %{"src" => src}}) do
    ["<audio src=\"", src, "\"/>\n"]
  end

  def blockquote(%Context{} = _context, next, _) do
    ["<quote>", next.(), "</quote>\n"]
  end

  def codeblock(%Context{} = _context, next, %{data: %{"syntax" => syntax}}) do
    ["<codeblock syntax=\"#{syntax}\">", next.(), "</codeblock>\n"]
  end

  def codeline(%Context{} = _context, _, %{nodes: nodes}) do
    Enum.map(nodes, fn n -> n.text end)
  end

  def a(%Context{} = _context, next, %{data: %{"href" => href}}) do
    ["<link href=\"#{escape_xml(href)}\">", next.(), "</link>\n"]
  end

  def a(%Context{} = _context, next, _) do
    next.()
  end

  def definition(%Context{} = _context, next, _) do
    ["<extra>", next.(), "</extra>\n"]
  end

  def text(%Context{} = _context, %{text: text, marks: marks}) do
    escape_xml(text) |> wrap_marks(marks)
  end

  def escape_xml(text) do
    String.replace(text, "&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("'", "&apos;")
    |> String.replace("\"", "&quot;")
  end

  def document(%Context{} = _context, next, %{data: %{id: id, title: title}}) do
    [
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
      "<!DOCTYPE workbook_page PUBLIC \"-//Carnegie Mellon University//DTD Workbook Page MathML 3.8//EN\" \"http://oli.web.cmu.edu/dtd/oli_workbook_page_mathml_3_8.dtd\">\n",
      "<workbook_page id=\"#{id}\"><head><title>#{escape_xml(title)}</title></head><body>\n",
      next.(),
      "</body></workbook_page>"
    ]
  end

  def package(%Context{} = _context, _, %{title: title}) do
    [
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
      "<package>\n",
      "<title>#{escape_xml(title)}</title>\n",
      "<description>description</description>\n",
      "</package>\n"
    ]
  end

  def organization(%Context{} = _context, next, %{id: id, title: title}) do
    [
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
      "<!DOCTYPE organization PUBLIC \"-//Carnegie Mellon University//DTD Content Organization Simple 2.3//EN\" \"http://oli.web.cmu.edu/dtd/oli_content_organization_simple_2_3.dtd\">\n",
      "<organization id=\"#{id}\" version=\"1.0\">\n",
      "<title>#{escape_xml(title)}</title>\n",
      "<description>organization description</description>\n",
      "<audience>Audience</audience>\n",
      "<labels sequence=\"Sequence\" unit=\"Unit\" module=\"Module\" section=\"Section\"/>\n",
      "<sequences>\n",
      "<sequence id=\"main_sequence\" category=\"content\" audience=\"all\">\n",
      "<title>Main Sequence</title>\n",
      next.(),
      "</sequence>\n",
      "</sequences></organization>\n"
    ]
  end

  def module(%Context{} = _context, next, %{id: id, title: title}) do
    [
      "<module id=\"#{id}\">\n",
      "<title>#{escape_xml(title)}</title>\n",
      next.(),
      "</module>\n"
    ]
  end

  def reference(%Context{} = _context, _, %{id: id}) do
    [
      "<item id=\"ref_#{id}\" scoring_mode=\"default\">\n",
      "<resourceref idref=\"#{id}\"/>\n",
      "</item>\n"
    ]
  end

  def wrap_marks(text, marks) do
    begin = %{
      "sub" => "sub",
      "sup" => "sup",
      "bold" => "em",
      "underline" => "",
      "code" => "code",
      "italic" => "em style=\"italic\"",
      "strikethrough" => "em style=\"line-through\"",
      "mark" => "em style=\"highlight\""
    }

    ending = %{
      "sub" => "sub",
      "sup" => "sup",
      "bold" => "em",
      "underline" => "",
      "code" => "code",
      "italic" => "em",
      "strikethrough" => "em",
      "mark" => "em"
    }

    Enum.reverse(marks)
    |> Enum.reduce(
      text,
      fn %{type: m}, t ->
        "<" <> Map.get(begin, m) <> ">" <> t <> "</" <> Map.get(ending, m) <> ">"
      end
    )
  end
end
