defmodule Conversion.Content.Writers.HTML do
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
    ["<thead>", next.(), "</thead>\n"]
  end

  def tbody(%Context{} = _context, next, _) do
    ["<tbody>", next.(), "</tbody>\n"]
  end

  def tfoot(%Context{} = _context, next, _) do
    ["<tfoot>", next.(), "</tfoot>\n"]
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

  def image(%Context{} = _context, _, %{data: data}) do
    src = Map.get(data, "src")

    height_width =
      case data do
        %{"height" => height, "width" => width} -> ["height=#{height} width=#{width}"]
        _ -> []
      end

    ["<img "] ++
      height_width ++
      [
        " style=\"display: block; max-height: 500px; margin-left: auto; margin-right: auto;\" src=\"",
        src,
        "\"/>\n"
      ]
  end

  def youtube(%Context{} = _context, _, %{data: %{"src" => src}}) do
    [
      """
      <iframe
        id="#{src}"
        width="640"
        height="476"
        src="https://www.youtube.com/embed/#{src}"
        frameBorder="0"
        style="display: block; margin-left: auto; margin-right: auto;"
      ></iframe>
      """
    ]
  end

  def ul(%Context{} = _context, next, _) do
    ["<ul>", next.(), "</ul>\n"]
  end

  def ol(%Context{} = _context, next, _) do
    ["<ol>", next.(), "</ol>\n"]
  end

  def li(%Context{} = _context, next, _) do
    ["<li>", next.(), "</li>\n"]
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

  def h1(%Context{} = _context, next, _) do
    ["<h1>", next.(), "</h1>\n"]
  end

  def h2(%Context{} = _context, next, _) do
    ["<h2>", next.(), "</h2>\n"]
  end

  def h3(%Context{} = _context, next, _) do
    ["<h3>", next.(), "</h3>\n"]
  end

  def h4(%Context{} = _context, next, _) do
    ["<h4>", next.(), "</h4>\n"]
  end

  def h5(%Context{} = _context, next, _) do
    ["<h5>", next.(), "</h5>\n"]
  end

  def h6(%Context{} = _context, next, _) do
    ["<h6>", next.(), "</h6>\n"]
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

  def package(%Context{} = _context, _, %{title: title}) do
    [
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
      "<package>\n",
      "<title>#{escape_xml(title)}</title>\n",
      "<description>description</description>\n",
      "</package>\n"
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
    map = %{
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
        "<" <> Map.get(map, m) <> ">" <> t <> "</" <> Map.get(map, m) <> ">"
      end
    )
  end
end
