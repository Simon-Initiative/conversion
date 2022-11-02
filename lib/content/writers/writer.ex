defmodule Conversion.Content.Writers.Writer do
  alias Conversion.Content.Model.Document
  alias Conversion.Content.Model.Block
  alias Conversion.Content.Model.Inline
  alias Conversion.Content.Model.Text
  alias Conversion.Content.Model.Organization
  alias Conversion.Content.Model.Package
  alias Conversion.Content.Model.Module
  alias Conversion.Content.Model.Reference

  alias Conversion.Content.Writers.Context

  @type next :: (() -> String.t())
  @type nodes :: [%{}]
  @type data :: %{}
  @type marks :: []

  @callback document(%Context{}, next, %Document{}) :: [any()]
  @callback organization(%Context{}, next, %Organization{}) :: [any()]
  @callback package(%Context{}, next, %Package{}) :: [any()]
  @callback module(%Context{}, next, %Module{}) :: [any()]
  @callback reference(%Context{}, next, %Reference{}) :: [any()]

  @callback p(%Context{}, next, %Block{}) :: [any()]
  @callback table(%Context{}, next, %Block{}) :: [any()]
  @callback caption(%Context{}, next, %Block{}) :: [any()]
  @callback tbody(%Context{}, next, %Block{}) :: [any()]
  @callback thead(%Context{}, next, %Block{}) :: [any()]
  @callback tfoot(%Context{}, next, %Block{}) :: [any()]
  @callback tr(%Context{}, next, %Block{}) :: [any()]
  @callback td(%Context{}, next, %Block{}) :: [any()]
  @callback th(%Context{}, next, %Block{}) :: [any()]
  @callback image(%Context{}, next, %Block{}) :: [any()]
  @callback youtube(%Context{}, next, %Block{}) :: [any()]
  @callback codeblock(%Context{}, next, %Block{}) :: [any()]
  @callback codeline(%Context{}, next, %Block{}) :: [any()]
  @callback ul(%Context{}, next, %Block{}) :: [any()]
  @callback dl(%Context{}, next, %Block{}) :: [any()]
  @callback dt(%Context{}, next, %Block{}) :: [any()]
  @callback dd(%Context{}, next, %Block{}) :: [any()]
  @callback ol(%Context{}, next, %Block{}) :: [any()]
  @callback li(%Context{}, next, %Block{}) :: [any()]
  @callback h1(%Context{}, next, %Block{}) :: [any()]
  @callback h2(%Context{}, next, %Block{}) :: [any()]
  @callback h3(%Context{}, next, %Block{}) :: [any()]
  @callback h4(%Context{}, next, %Block{}) :: [any()]
  @callback h5(%Context{}, next, %Block{}) :: [any()]
  @callback h6(%Context{}, next, %Block{}) :: [any()]
  @callback blockquote(%Context{}, next, %Block{}) :: [any()]
  @callback audio(%Context{}, next, %Block{}) :: [any()]
  @callback a(%Context{}, next, %Inline{}) :: [any()]
  @callback definition(%Context{}, next, %Inline{}) :: [any()]
  @callback text(%Context{}, %Text{}) :: [any()]

  def render(%Context{} = context, %Document{nodes: nodes} = doc, impl) do
    next = fn -> render(context, nodes, impl) end
    impl.document(context, next, doc)
  end

  def render(%Context{} = context, %Organization{nodes: nodes} = doc, impl) do
    next = fn -> render(context, nodes, impl) end
    impl.organization(context, next, doc)
  end

  def render(%Context{} = context, %Package{} = package, impl) do
    impl.package(context, true, package)
  end

  def render(%Context{} = context, %Module{nodes: nodes} = doc, impl) do
    next = fn -> render(context, nodes, impl) end
    impl.module(context, next, doc)
  end

  def render(%Context{} = context, %Reference{} = ref, impl) do
    next = fn -> "" end
    impl.reference(context, next, ref)
  end

  def render(%Context{} = context, %Block{type: type, nodes: nodes} = block, impl) do
    next = fn -> render(context, nodes, impl) end

    case type do
      "paragraph" -> impl.p(context, next, block)
      "table" -> impl.table(context, next, block)
      "caption" -> impl.caption(context, next, block)
      "thead" -> impl.thead(context, next, block)
      "tbody" -> impl.tbody(context, next, block)
      "tfoot" -> impl.tfoot(context, next, block)
      "tr" -> impl.tr(context, next, block)
      "td" -> impl.td(context, next, block)
      "th" -> impl.th(context, next, block)
      "image" -> impl.image(context, next, block)
      "youtube" -> impl.youtube(context, next, block)
      "unordered-list" -> impl.ul(context, next, block)
      "ordered-list" -> impl.ol(context, next, block)
      "dl" -> impl.dl(context, next, block)
      "dt" -> impl.dt(context, next, block)
      "dd" -> impl.dd(context, next, block)
      "list-item" -> impl.li(context, next, block)
      "codeblock" -> impl.codeblock(context, next, block)
      "codeline" -> impl.codeline(context, next, block)
      "heading-one" -> impl.h1(context, next, block)
      "heading-two" -> impl.h2(context, next, block)
      "heading-three" -> impl.h3(context, next, block)
      "heading-four" -> impl.h4(context, next, block)
      "heading-five" -> impl.h5(context, next, block)
      "heading-six" -> impl.h6(context, next, block)
      "blockquote" -> impl.blockquote(context, next, block)
      "audio" -> impl.audio(context, next, block)
    end
  end

  def render(%Context{} = context, %Inline{type: type, nodes: nodes} = inline, impl) do
    next = fn -> render(context, nodes, impl) end

    case type do
      "link" -> impl.a(context, next, inline)
      "definition" -> impl.definition(context, next, inline)
    end
  end

  def render(%Context{} = context, %Text{} = text, impl) do
    impl.text(context, text)
  end

  def render(%Context{} = context, text, impl) when is_binary(text) do
    impl.text(context, %Text{text: text})
  end

  def render(%Context{} = context, nodes, impl) when is_list(nodes) do
    Enum.map(nodes, fn n -> render(context, n, impl) end)
  end
end
